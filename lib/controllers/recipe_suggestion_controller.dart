import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pantry_item.dart';
import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../models/user_recipe_matches.dart';

/// Provides recipe suggestions that satisfy:
/// - FR2.1: all ingredients are already in the pantry (core match).
/// - FR2.2: near matches that only miss a small number of ingredients (flexible).
/// The controller can optionally call an AI edge function to enrich suggestions.
class RecipeSuggestion {
  final Recipe recipe;
  final UserRecipeMatch match;
  final List<RecipeIngredient> matchedIngredients;
  final List<RecipeIngredient> missingIngredients;
  final double coverage;
  final String? aiAdvice;

  const RecipeSuggestion({
    required this.recipe,
    required this.match,
    required this.matchedIngredients,
    required this.missingIngredients,
    required this.coverage,
    this.aiAdvice,
  });

  bool get isFullMatch => missingIngredients.isEmpty;
  bool get isFlexibleMatch => !isFullMatch;
}

/// Result model for internal match evaluation.
class _MatchResult {
  final List<RecipeIngredient> matched;
  final List<RecipeIngredient> missing;
  final double coverage;

  _MatchResult({
    required this.matched,
    required this.missing,
    required this.coverage,
  });
}

class _RecipeSeed {
  final String title;
  final int ingredientId;
  final double quantity;
  final String unit;
  final String description;
  final String instructions;

  _RecipeSeed({
    required this.title,
    required this.ingredientId,
    required this.quantity,
    required this.unit,
    required this.description,
    required this.instructions,
  });
}

class RecipeSuggestionController {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _recipesTable = 'recipes';
  static const String _aiFunctionName = 'ai-recipe-suggestions';

  String? get _currentProfileId => _supabase.auth.currentUser?.id;

  /// Returns a sorted list of suggestions (full matches first, then flexible).
  Future<List<RecipeSuggestion>> getSuggestedRecipes({
    int maxMissingForFlexible = 2,
    double minCoverageForFlexible = 0.6,
    bool callAiAdvisor = true,
    bool seedIfEmpty = false,
    bool checkQuantity = true,
    bool autoGenerateFromPantry = true,
    String? profileIdOverride,
  }) async {
    final profileId = profileIdOverride ?? _currentProfileId;
    if (profileId == null) throw Exception('User not authenticated');

    // Optional: seed sample data only when explicitly requested.
    if (seedIfEmpty) {
      await _ensureSeedDataIfEmpty(profileId);
    }

    final pantryItems = await _fetchPantryItemsForProfile(profileId);
    final pantryByIngredient = {
      for (final item in pantryItems) item.ingredientId: item,
    };

    // Optionally auto-create simple recipes from pantry ingredients for this user.
    if (autoGenerateFromPantry) {
      await _ensureRecipesFromPantry(profileId, pantryItems);
    }

    var recipes = await _fetchRecipesWithIngredients();
    // Nếu sau khi auto-generate vẫn chưa có công thức, thử lại một lần nữa (phòng khi insert trễ).
    if (recipes.isEmpty && autoGenerateFromPantry && pantryItems.isNotEmpty) {
      await _ensureRecipesFromPantry(profileId, pantryItems);
      recipes = await _fetchRecipesWithIngredients();
    }

    final suggestions = <RecipeSuggestion>[];

    for (final recipe in recipes) {
      if (recipe.recipeId == null) continue;
      final ingredients = recipe.ingredients ?? const <RecipeIngredient>[];
      if (ingredients.isEmpty) continue;

      final matchResult = _evaluateMatch(
        ingredients: ingredients,
        pantryByIngredient: pantryByIngredient,
        checkQuantity: checkQuantity,
      );

      final total = ingredients.length;
      final coverage = matchResult.coverage;
      final isFullMatch = matchResult.missing.isEmpty;
      final isFlexibleMatch =
          !isFullMatch &&
          matchResult.missing.length <= maxMissingForFlexible &&
          coverage >= minCoverageForFlexible;

      if (!isFullMatch && !isFlexibleMatch) continue;

      final match = UserRecipeMatch(
        profileId: profileId,
        recipeId: recipe.recipeId!,
        totalIngredients: total,
        availableIngredients: matchResult.matched.length,
        missingIngredients: matchResult.missing.length,
      );

      final aiAdvice = callAiAdvisor
          ? await _maybeCallAiAdvisor(
              recipe,
              matchResult.matched,
              matchResult.missing,
            )
          : null;

      suggestions.add(
        RecipeSuggestion(
          recipe: recipe,
          match: match,
          matchedIngredients: matchResult.matched,
          missingIngredients: matchResult.missing,
          coverage: coverage,
          aiAdvice: aiAdvice,
        ),
      );
    }

    suggestions.sort((a, b) {
      final missingA = a.match.missingIngredients ?? 0;
      final missingB = b.match.missingIngredients ?? 0;
      if (missingA != missingB) return missingA.compareTo(missingB);
      return b.coverage.compareTo(a.coverage);
    });

    return suggestions;
  }

  Future<List<Recipe>> _fetchRecipesWithIngredients() async {
    final response = await _supabase
        .from(_recipesTable)
        .select('''
          *,
          recipe_ingredients(
            *,
            ingredients(*)
          )
        ''')
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Recipe.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<String?> _maybeCallAiAdvisor(
    Recipe recipe,
    List<RecipeIngredient> matched,
    List<RecipeIngredient> missing,
  ) async {
    try {
      final response = await _supabase.functions.invoke(
        _aiFunctionName,
        body: {
          'recipe_title': recipe.title,
          'description': recipe.description,
          'instructions': recipe.instructions,
          'available': matched.map(_ingredientToPayload).toList(),
          'missing': missing.map(_ingredientToPayload).toList(),
        },
      );

      final data = response.data;
      if (data is Map) {
        if (data['advice'] is String) return data['advice'] as String;
        if (data['message'] is String) return data['message'] as String;
      }
      if (data is String) return data;
      return null;
    } catch (_) {
      // AI enrichment is optional; silently fall back to rule-based matches.
      return null;
    }
  }

  Map<String, dynamic> _ingredientToPayload(RecipeIngredient ingredient) {
    return {
      'ingredient_id': ingredient.ingredientId,
      'quantity': ingredient.quantity,
      'unit': ingredient.unit.toDbValue(),
      'name': ingredient.ingredient?.name,
    };
  }

  _MatchResult _evaluateMatch({
    required List<RecipeIngredient> ingredients,
    required Map<int, PantryItem> pantryByIngredient,
    required bool checkQuantity,
  }) {
    final matched = <RecipeIngredient>[];
    final missing = <RecipeIngredient>[];

    final qtyByIngredient = <int, double>{};
    for (final item in pantryByIngredient.values) {
      qtyByIngredient.update(
        item.ingredientId,
        (prev) => prev + item.quantity,
        ifAbsent: () => item.quantity,
      );
    }

    for (final recipeIng in ingredients) {
      final pantryItem = pantryByIngredient[recipeIng.ingredientId];
      if (pantryItem == null) {
        missing.add(recipeIng);
        continue;
      }

      if (!checkQuantity) {
        matched.add(recipeIng);
        continue;
      }

      final totalQty = qtyByIngredient[recipeIng.ingredientId] ?? 0.0;
      final sameUnit =
          pantryItem.unit.toDbValue() == recipeIng.unit.toDbValue();
      final hasEnough = sameUnit && totalQty >= recipeIng.quantity;

      if (hasEnough) {
        matched.add(recipeIng);
      } else {
        missing.add(recipeIng);
      }
    }

    final total = ingredients.length;
    final coverage = total == 0 ? 0.0 : matched.length / total;

    return _MatchResult(
      matched: matched,
      missing: missing,
      coverage: coverage,
    );
  }

  /// Auto-generate simple recipes from pantry ingredients for the current user (idempotent).
  Future<void> _ensureRecipesFromPantry(
    String profileId,
    List<PantryItem> pantryItems,
  ) async {
    if (pantryItems.isEmpty) return;

    // Fetch existing recipe titles to avoid duplicates.
    final existingRes = await _supabase
        .from(_recipesTable)
        .select('recipe_id, title')
        .isFilter('deleted_at', null);
    final existingTitles = <String, int>{};
    for (final r in (existingRes as List)) {
      if (r['title'] != null && r['recipe_id'] != null) {
        existingTitles[r['title'] as String] = r['recipe_id'] as int;
      }
    }

    final seeds = <_RecipeSeed>[];
    for (final item in pantryItems) {
      final nameCandidate = (item.ingredient?.name ?? '').trim();
      final ingName =
          nameCandidate.isNotEmpty ? nameCandidate : 'Nguyên liệu #${item.ingredientId}';
      final title = 'Món với $ingName';
      if (existingTitles.containsKey(title)) continue;

      seeds.add(
        _RecipeSeed(
          title: title,
          ingredientId: item.ingredientId,
          unit: item.unit.toDbValue(),
          quantity: item.quantity > 0 ? item.quantity : 100,
          description: 'Món đơn giản sử dụng $ingName từ kho của bạn.',
          instructions: 'Sơ chế, nêm nếm và chế biến theo khẩu vị.',
        ),
      );
    }

    if (seeds.isEmpty) return;

    final recipePayload = seeds
        .map(
          (s) => {
            'title': s.title,
            'description': s.description,
            'instructions': s.instructions,
            'cooking_time_minutes': 15,
            'servings': 2,
            'difficulty': 'easy',
            'meal_type': 'dinner',
          },
        )
        .toList();

    List<dynamic> inserted;
    try {
      inserted = await _supabase
          .from(_recipesTable)
          .upsert(recipePayload, onConflict: 'title')
          .select('recipe_id, title');
    } catch (e) {
      // If insert fails (e.g., constraint), abort silently to avoid breaking UI.
      return;
    }

    for (final r in inserted) {
      if (r['title'] != null && r['recipe_id'] != null) {
        existingTitles[r['title'] as String] = r['recipe_id'] as int;
      }
    }

    final recipeIngRows = <Map<String, dynamic>>[];
    for (final seed in seeds) {
      final recipeId = existingTitles[seed.title];
      if (recipeId == null) continue;
      recipeIngRows.add({
        'recipe_id': recipeId,
        'ingredient_id': seed.ingredientId,
        'quantity': seed.quantity,
        'unit': seed.unit,
      });
    }

    if (recipeIngRows.isNotEmpty) {
      await _supabase
          .from('recipe_ingredients')
          .upsert(recipeIngRows, onConflict: 'recipe_id,ingredient_id');
    }
  }

  Future<List<PantryItem>> _fetchPantryItemsForProfile(String profileId) async {
    final response = await _supabase
        .from('pantry_items')
        .select('*, ingredients(*)')
        .eq('profile_id', profileId)
        .isFilter('deleted_at', null) as List;

    return response
        .map((e) => PantryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Seed sample ingredients/recipes/pantry for the current profile if none exist.
  /// Idempotent: uses upsert and skips when data already present.
  Future<void> _ensureSeedDataIfEmpty(String profileId) async {
    final existing = await _supabase
        .from(_recipesTable)
        .select('recipe_id')
        .limit(1);
    if (existing.isNotEmpty) return;

    final seedIngredients = [
      {
        'name': 'Ức gà',
        'category': 'thịt',
        'unit': 'g',
        'name_normalized': 'uc ga',
      },
      {
        'name': 'Trứng gà',
        'category': 'thịt',
        'unit': 'cái',
        'name_normalized': 'trung ga',
      },
      {
        'name': 'Gạo trắng',
        'category': 'khác',
        'unit': 'g',
        'name_normalized': 'gao trang',
      },
      {
        'name': 'Cà rốt',
        'category': 'rau',
        'unit': 'g',
        'name_normalized': 'ca rot',
      },
      {
        'name': 'Bông cải xanh',
        'category': 'rau',
        'unit': 'g',
        'name_normalized': 'bong cai xanh',
      },
      {
        'name': 'Hành tây',
        'category': 'rau',
        'unit': 'g',
        'name_normalized': 'hanh tay',
      },
      {'name': 'Tỏi', 'category': 'rau', 'unit': 'g', 'name_normalized': 'toi'},
      {
        'name': 'Dầu ô liu',
        'category': 'khác',
        'unit': 'ml',
        'name_normalized': 'dau o liu',
      },
      {
        'name': 'Muối',
        'category': 'khác',
        'unit': 'g',
        'name_normalized': 'muoi',
      },
      {
        'name': 'Tiêu đen',
        'category': 'khác',
        'unit': 'g',
        'name_normalized': 'tieu den',
      },
      {
        'name': 'Nước mắm',
        'category': 'khác',
        'unit': 'ml',
        'name_normalized': 'nuoc mam',
      },
    ];

    final seedRecipes = [
      {
        'title': 'Cơm gà xé rau củ',
        'description': 'Cơm trắng với ức gà xé và rau củ xào.',
        'instructions':
            'Nấu cơm; luộc/chần ức gà, xé sợi; xào rau với dầu, nêm muối tiêu; trộn gà với rau, ăn kèm cơm.',
        'cooking_time_minutes': 35,
        'servings': 2,
        'difficulty': 'easy',
        'meal_type': 'lunch',
        'image_url': null,
      },
      {
        'title': 'Trứng chiên hành tây',
        'description': 'Trứng chiên đơn giản với hành tây, tiêu.',
        'instructions':
            'Đánh trứng, nêm; phi hành tây, đổ trứng, chiên vàng hai mặt.',
        'cooking_time_minutes': 10,
        'servings': 1,
        'difficulty': 'easy',
        'meal_type': 'breakfast',
        'image_url': null,
      },
      {
        'title': 'Gà xào bông cải',
        'description': 'Ức gà xào bông cải, cà rốt, tỏi.',
        'instructions':
            'Ướp gà muối tiêu; phi tỏi; xào gà; cho rau, nêm; xào chín tới.',
        'cooking_time_minutes': 20,
        'servings': 2,
        'difficulty': 'easy',
        'meal_type': 'dinner',
        'image_url': null,
      },
    ];

    await _supabase
        .from('ingredients')
        .upsert(seedIngredients, onConflict: 'name')
        .select('ingredient_id, name');

    final insertedRecipes = await _supabase
        .from(_recipesTable)
        .upsert(seedRecipes, onConflict: 'title')
        .select('recipe_id, title');

    // Map recipe title -> id
    final recipeIdByTitle = <String, int>{};
    for (final r in insertedRecipes) {
      if (r['title'] != null && r['recipe_id'] != null) {
        recipeIdByTitle[r['title'] as String] = r['recipe_id'] as int;
      }
    }

    // Fetch ingredient ids to map by name
    final ingRows = await _supabase
        .from('ingredients')
        .select('ingredient_id, name');
    final ingIdByName = <String, int>{};
    for (final i in ingRows) {
      if (i['name'] != null && i['ingredient_id'] != null) {
        ingIdByName[i['name'] as String] = i['ingredient_id'] as int;
      }
    }

    int? rId(String title) => recipeIdByTitle[title];
    int? iId(String name) => ingIdByName[name];

    final seedRecipeIngredients =
        [
              // Cơm gà xé rau củ
              {
                'recipe_id': rId('Cơm gà xé rau củ'),
                'ingredient_id': iId('Ức gà'),
                'quantity': 300,
                'unit': 'g',
              },
              {
                'recipe_id': rId('Cơm gà xé rau củ'),
                'ingredient_id': iId('Gạo trắng'),
                'quantity': 200,
                'unit': 'g',
              },
              {
                'recipe_id': rId('Cơm gà xé rau củ'),
                'ingredient_id': iId('Cà rốt'),
                'quantity': 80,
                'unit': 'g',
              },
              {
                'recipe_id': rId('Cơm gà xé rau củ'),
                'ingredient_id': iId('Bông cải xanh'),
                'quantity': 120,
                'unit': 'g',
              },
              {
                'recipe_id': rId('Cơm gà xé rau củ'),
                'ingredient_id': iId('Dầu ô liu'),
                'quantity': 10,
                'unit': 'ml',
              },
              {
                'recipe_id': rId('Cơm gà xé rau củ'),
                'ingredient_id': iId('Muối'),
                'quantity': 3,
                'unit': 'g',
              },
              {
                'recipe_id': rId('Cơm gà xé rau củ'),
                'ingredient_id': iId('Tiêu đen'),
                'quantity': 2,
                'unit': 'g',
              },
              // Trứng chiên hành tây
              {
                'recipe_id': rId('Trứng chiên hành tây'),
                'ingredient_id': iId('Trứng gà'),
                'quantity': 2,
                'unit': 'cái',
              },
              {
                'recipe_id': rId('Trứng chiên hành tây'),
                'ingredient_id': iId('Hành tây'),
                'quantity': 60,
                'unit': 'g',
              },
              {
                'recipe_id': rId('Trứng chiên hành tây'),
                'ingredient_id': iId('Dầu ô liu'),
                'quantity': 8,
                'unit': 'ml',
              },
              {
                'recipe_id': rId('Trứng chiên hành tây'),
                'ingredient_id': iId('Muối'),
                'quantity': 2,
                'unit': 'g',
              },
              {
                'recipe_id': rId('Trứng chiên hành tây'),
                'ingredient_id': iId('Tiêu đen'),
                'quantity': 1,
                'unit': 'g',
              },
              // Gà xào bông cải
              {
                'recipe_id': rId('Gà xào bông cải'),
                'ingredient_id': iId('Ức gà'),
                'quantity': 250,
                'unit': 'g',
              },
              {
                'recipe_id': rId('Gà xào bông cải'),
                'ingredient_id': iId('Bông cải xanh'),
                'quantity': 150,
                'unit': 'g',
              },
              {
                'recipe_id': rId('Gà xào bông cải'),
                'ingredient_id': iId('Cà rốt'),
                'quantity': 60,
                'unit': 'g',
              },
              {
                'recipe_id': rId('Gà xào bông cải'),
                'ingredient_id': iId('Tỏi'),
                'quantity': 6,
                'unit': 'g',
              },
              {
                'recipe_id': rId('Gà xào bông cải'),
                'ingredient_id': iId('Dầu ô liu'),
                'quantity': 12,
                'unit': 'ml',
              },
              {
                'recipe_id': rId('Gà xào bông cải'),
                'ingredient_id': iId('Muối'),
                'quantity': 3,
                'unit': 'g',
              },
              {
                'recipe_id': rId('Gà xào bông cải'),
                'ingredient_id': iId('Tiêu đen'),
                'quantity': 2,
                'unit': 'g',
              },
              {
                'recipe_id': rId('Gà xào bông cải'),
                'ingredient_id': iId('Nước mắm'),
                'quantity': 8,
                'unit': 'ml',
              },
            ]
            .where((e) => e['recipe_id'] != null && e['ingredient_id'] != null)
            .toList();

    if (seedRecipeIngredients.isNotEmpty) {
      await _supabase
          .from('recipe_ingredients')
          .upsert(seedRecipeIngredients, onConflict: 'recipe_id,ingredient_id');
    }

    // Seed pantry items for the current user only if they don't already have that ingredient.
    final existingPantry = await _supabase
        .from('pantry_items')
        .select('ingredient_id')
        .eq('profile_id', profileId);
    final existingIngIds = <int>{};
    for (final p in existingPantry) {
      if (p['ingredient_id'] is int) {
        existingIngIds.add(p['ingredient_id'] as int);
      }
    }

    final pantrySeeds =
        [
              {
                'ingredient_id': iId('Ức gà'),
                'quantity': 400,
                'unit': 'g',
                'purchase_date': DateTime.now()
                    .subtract(const Duration(days: 1))
                    .toIso8601String()
                    .split('T')
                    .first,
                'expiry_date': DateTime.now()
                    .add(const Duration(days: 2))
                    .toIso8601String()
                    .split('T')
                    .first,
              },
              {
                'ingredient_id': iId('Gạo trắng'),
                'quantity': 1000,
                'unit': 'g',
                'purchase_date': DateTime.now()
                    .subtract(const Duration(days: 10))
                    .toIso8601String()
                    .split('T')
                    .first,
                'expiry_date': DateTime.now()
                    .add(const Duration(days: 90))
                    .toIso8601String()
                    .split('T')
                    .first,
              },
              {
                'ingredient_id': iId('Cà rốt'),
                'quantity': 150,
                'unit': 'g',
                'purchase_date': DateTime.now()
                    .subtract(const Duration(days: 2))
                    .toIso8601String()
                    .split('T')
                    .first,
                'expiry_date': DateTime.now()
                    .add(const Duration(days: 5))
                    .toIso8601String()
                    .split('T')
                    .first,
              },
              {
                'ingredient_id': iId('Bông cải xanh'),
                'quantity': 80,
                'unit': 'g',
                'purchase_date': DateTime.now()
                    .subtract(const Duration(days: 1))
                    .toIso8601String()
                    .split('T')
                    .first,
                'expiry_date': DateTime.now()
                    .add(const Duration(days: 3))
                    .toIso8601String()
                    .split('T')
                    .first,
              },
              {
                'ingredient_id': iId('Hành tây'),
                'quantity': 100,
                'unit': 'g',
                'purchase_date': DateTime.now()
                    .subtract(const Duration(days: 2))
                    .toIso8601String()
                    .split('T')
                    .first,
                'expiry_date': DateTime.now()
                    .add(const Duration(days: 7))
                    .toIso8601String()
                    .split('T')
                    .first,
              },
              {
                'ingredient_id': iId('Trứng gà'),
                'quantity': 6,
                'unit': 'cái',
                'purchase_date': DateTime.now()
                    .subtract(const Duration(days: 3))
                    .toIso8601String()
                    .split('T')
                    .first,
                'expiry_date': DateTime.now()
                    .add(const Duration(days: 10))
                    .toIso8601String()
                    .split('T')
                    .first,
              },
              {
                'ingredient_id': iId('Dầu ô liu'),
                'quantity': 200,
                'unit': 'ml',
                'purchase_date': DateTime.now()
                    .subtract(const Duration(days: 15))
                    .toIso8601String()
                    .split('T')
                    .first,
                'expiry_date': DateTime.now()
                    .add(const Duration(days: 120))
                    .toIso8601String()
                    .split('T')
                    .first,
              },
              {
                'ingredient_id': iId('Muối'),
                'quantity': 300,
                'unit': 'g',
                'purchase_date': DateTime.now()
                    .subtract(const Duration(days: 20))
                    .toIso8601String()
                    .split('T')
                    .first,
                'expiry_date': DateTime.now()
                    .add(const Duration(days: 365))
                    .toIso8601String()
                    .split('T')
                    .first,
              },
              {
                'ingredient_id': iId('Tiêu đen'),
                'quantity': 50,
                'unit': 'g',
                'purchase_date': DateTime.now()
                    .subtract(const Duration(days: 20))
                    .toIso8601String()
                    .split('T')
                    .first,
                'expiry_date': DateTime.now()
                    .add(const Duration(days: 365))
                    .toIso8601String()
                    .split('T')
                    .first,
              },
            ]
            .where((p) => p['ingredient_id'] != null)
            .where((p) => !existingIngIds.contains(p['ingredient_id'] as int))
            .toList();

    if (pantrySeeds.isNotEmpty) {
      await _supabase
          .from('pantry_items')
          .insert(
            pantrySeeds.map((p) => {...p, 'profile_id': profileId}).toList(),
          );
    }
  }
}
