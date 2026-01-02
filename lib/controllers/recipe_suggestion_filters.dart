import '../models/enums.dart';
import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import 'recipe_suggestion_controller.dart';

/// Helper to normalize and validate filter selections coming from
/// the recipe filter dialogs (default + validation views), and to
/// apply them to recipe suggestions.
class RecipeFilterOptions {
  /// Time keys match radio values in the filter dialogs.
  /// Allowed: '', 'under15', '15to30', 'over30', 'none'
  final String timeKey;
  final Set<String> mealLabels; // e.g. {'Sáng', 'Trưa'}
  final Set<String> cuisineLabels; // e.g. {'Việt', 'Á'}
  final Set<String> ingredientLabels; // e.g. {'Cà rốt', 'Thịt bò'}

  const RecipeFilterOptions({
    required this.timeKey,
    required this.mealLabels,
    required this.cuisineLabels,
    this.ingredientLabels = const <String>{},
  });

  bool get isComplete =>
      timeKey.isNotEmpty && mealLabels.isNotEmpty && cuisineLabels.isNotEmpty;

  /// Factory to create options from raw selections in the dialogs.
  factory RecipeFilterOptions.fromSelections({
    required String selectedTime,
    required Set<String> selectedMeals,
    required Set<String> selectedCuisines,
    Set<String> selectedIngredients = const <String>{},
  }) {
    return RecipeFilterOptions(
      timeKey: selectedTime,
      mealLabels: Set<String>.from(selectedMeals),
      cuisineLabels: Set<String>.from(selectedCuisines),
      ingredientLabels: Set<String>.from(selectedIngredients),
    );
  }
}

class RecipeSuggestionFilters {
  /// Validate completeness used by the validation dialog.
  static (bool isValid, String? message) validateComplete(
    RecipeFilterOptions options,
  ) {
    if (options.timeKey.isEmpty) {
      return (false, 'Hãy chọn thời gian nấu.');
    }
    if (options.mealLabels.isEmpty) {
      return (false, 'Hãy chọn loại bữa.');
    }
    if (options.cuisineLabels.isEmpty) {
      return (false, 'Hãy chọn ẩm thực.');
    }
    return (true, null);
  }

  /// Apply filters to a list of recipe suggestions.
  static List<RecipeSuggestion> applyToSuggestions(
    List<RecipeSuggestion> suggestions,
    RecipeFilterOptions options, {
    bool lenientMissing = true,
  }) {
    final mealEnums = _mapMeals(options.mealLabels);
    final hasMealSelection = options.mealLabels.isNotEmpty;
    final cuisines = _normalizeCuisines(options.cuisineLabels);
    final ingredients = _normalizeIngredients(options.ingredientLabels);

    return suggestions.where((s) {
      final r = s.recipe;
      return _matchTime(r, options.timeKey, lenientMissing) &&
          _matchMeal(r, mealEnums, lenientMissing, hasMealSelection) &&
          _matchCuisine(r, cuisines, lenientMissing) &&
          _matchIngredient(s, ingredients);
    }).toList();
  }

  /// Apply filters directly to recipes (if suggestions not yet computed).
  static List<Recipe> applyToRecipes(
    List<Recipe> recipes,
    RecipeFilterOptions options, {
    bool lenientMissing = true,
  }) {
    final mealEnums = _mapMeals(options.mealLabels);
    final hasMealSelection = options.mealLabels.isNotEmpty;
    final cuisines = _normalizeCuisines(options.cuisineLabels);
    final ingredients = _normalizeIngredients(options.ingredientLabels);

    return recipes.where((r) {
      return _matchTime(r, options.timeKey, lenientMissing) &&
          _matchMeal(r, mealEnums, lenientMissing, hasMealSelection) &&
          _matchCuisine(r, cuisines, lenientMissing) &&
          _matchIngredientInRecipe(r, ingredients);
    }).toList();
  }

  static bool _matchTime(
    Recipe recipe,
    String timeKey,
    bool lenientMissing,
  ) {
    if (timeKey.isEmpty || timeKey == 'none') return true;
    final minutes = recipe.cookingTimeMinutes;
    // Cho qua nếu thiếu dữ liệu khi ở chế độ lenient
    if (minutes == null) return lenientMissing;
    switch (timeKey) {
      case 'under15':
        return minutes < 15;
      case '15to30':
        return minutes >= 15 && minutes <= 30;
      case 'over30':
        return minutes > 30;
      default:
        return true;
    }
  }

  static bool _matchMeal(
    Recipe recipe,
    Set<MealTypeEnum> allowed,
    bool lenientMissing,
    bool hasSelection,
  ) {
    // Nếu người dùng có chọn bữa nhưng không map được (ví dụ chọn "Bữa phụ"),
    // thì không có món nào phù hợp.
    if (allowed.isEmpty) return hasSelection ? false : true;
    final meal = recipe.mealType;
    if (meal == null) return lenientMissing;
    return allowed.contains(meal);
  }

  static bool _matchCuisine(
    Recipe recipe,
    Set<String> cuisines,
    bool lenientMissing,
  ) {
    if (cuisines.isEmpty) return true;
    final c = recipe.cuisine?.trim().toLowerCase();
    if (c == null || c.isEmpty) return lenientMissing;
    return cuisines.any((target) => c.contains(target) || target.contains(c));
  }

  static Set<MealTypeEnum> _mapMeals(Set<String> labels) {
    final normalized = labels.map((e) => e.trim().toLowerCase()).toSet();
    final result = <MealTypeEnum>{};
    for (final label in normalized) {
      if (label.contains('sáng')) {
        result.add(MealTypeEnum.breakfast);
      } else if (label.contains('trưa')) {
        result.add(MealTypeEnum.lunch);
      } else if (label.contains('tối')) {
        result.add(MealTypeEnum.dinner);
      }
      // 'Bữa phụ' không map vì chưa có enum tương ứng.
    }
    return result;
  }

  static Set<String> _normalizeCuisines(Set<String> labels) {
    final mapped = <String>{};
    for (final raw in labels) {
      final v = raw.trim().toLowerCase();
      if (v.isEmpty) continue;
      switch (v) {
        case 'việt':
        case 'vietnam':
        case 'vietnamese':
          mapped.add('việt');
          break;
        case 'á':
        case 'asian':
          mapped.add('á');
          break;
        case 'âu':
        case 'europe':
        case 'european':
          mapped.add('âu');
          break;
        case 'mỹ':
        case 'us':
        case 'american':
          mapped.add('mỹ');
          break;
        case 'chay':
        case 'vegetarian':
        case 'vegan':
          mapped.add('chay');
          break;
        case 'khác':
        case 'other':
          mapped.add('khác');
          break;
        default:
          mapped.add(v);
      }
    }
    return mapped;
  }

  static Set<String> _normalizeIngredients(Set<String> labels) {
    return labels.map((label) => label.trim().toLowerCase()).toSet();
  }

  static bool _matchIngredient(
    RecipeSuggestion suggestion,
    Set<String> ingredients,
  ) {
    if (ingredients.isEmpty) return true;
    
    // Check if any of the recipe ingredients match the filter
    final recipeIngredients = suggestion.recipe.ingredients ?? <RecipeIngredient>[];
    for (final recipeIng in recipeIngredients) {
      final ingredientName = recipeIng.ingredient?.name;
      final ingName = ingredientName?.trim().toLowerCase() ?? '';
      if (ingName.isNotEmpty) {
        for (final filterIng in ingredients) {
          if (ingName.contains(filterIng) || filterIng.contains(ingName)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  static bool _matchIngredientInRecipe(
    Recipe recipe,
    Set<String> ingredients,
  ) {
    if (ingredients.isEmpty) return true;
    
    // Check if any of the recipe ingredients match the filter
    final recipeIngredients = recipe.ingredients ?? <RecipeIngredient>[];
    for (final recipeIng in recipeIngredients) {
      final ingredientName = recipeIng.ingredient?.name;
      final ingName = ingredientName?.trim().toLowerCase() ?? '';
      if (ingName.isNotEmpty) {
        for (final filterIng in ingredients) {
          if (ingName.contains(filterIng) || filterIng.contains(ingName)) {
            return true;
          }
        }
      }
    }
    return false;
  }
}

