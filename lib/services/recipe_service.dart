import 'package:supabase_flutter/supabase_flutter.dart';

import '../controllers/recipe_suggestion_controller.dart';
import '../controllers/recipe_suggestion_filters.dart';
import '../models/enums.dart';
import '../models/recipe_ingredient.dart';
import '../views/recipes/components/recipe_card_list.dart';

/// Single source of truth cho danh sách recipes hiển thị trong UI.
///
/// Mục tiêu: Recipes tab và bottom sheet chọn công thức phải lấy từ cùng 1 luồng
/// load/filter/map dữ liệu.
class RecipeService {
  RecipeService._();

  static final RecipeService instance = RecipeService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Load danh sách RecipeCardModel theo đúng logic của Recipes tab.
  ///
  /// - Dùng cùng nguồn: RecipeSuggestionController + RecipeSuggestionFilters.
  /// - Không seed/hardcode ở đây.
  Future<List<RecipeCardModel>> loadRecipeCards({
    required RecipeFilterOptions filters,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return const [];

    final controller = RecipeSuggestionController();
    final suggestions = await controller.getSuggestedRecipes(
      callAiAdvisor: false,
      seedIfEmpty: false,
      checkQuantity: false,
    );

    final filtered = RecipeSuggestionFilters.applyToSuggestions(
      suggestions,
      filters,
      lenientMissing: true,
    );

    return filtered.map(_mapToCardModel).toList();
  }

  RecipeCardModel _mapToCardModel(RecipeSuggestion suggestion) {
    final recipe = suggestion.recipe;
    final available =
        suggestion.match.availableIngredients ??
        suggestion.matchedIngredients.length;
    final total =
        suggestion.match.totalIngredients ??
        (suggestion.matchedIngredients.length +
            suggestion.missingIngredients.length);
    final missing =
        suggestion.match.missingIngredients ??
        suggestion.missingIngredients.length;

    RecipeDifficulty _diff(RecipeDifficultyEnum? d) {
      switch (d) {
        case RecipeDifficultyEnum.medium:
          return RecipeDifficulty.medium;
        case RecipeDifficultyEnum.hard:
          return RecipeDifficulty.hard;
        case RecipeDifficultyEnum.easy:
        case null:
          return RecipeDifficulty.easy;
      }
    }

    RecipeMealTime _meal(MealTypeEnum? m) {
      switch (m) {
        case MealTypeEnum.lunch:
          return RecipeMealTime.lunch;
        case MealTypeEnum.dinner:
          return RecipeMealTime.dinner;
        case MealTypeEnum.breakfast:
        case null:
          return RecipeMealTime.breakfast;
      }
    }

    String _timeLabel(int? minutes) {
      if (minutes == null || minutes <= 0) return 'Không rõ thời gian';
      return '$minutes phút';
    }

    String _ingredientName(RecipeIngredient ri) =>
        ri.ingredient?.name ?? 'Nguyên liệu #${ri.ingredientId}';

    final availableNames = suggestion.matchedIngredients
        .map(_ingredientName)
        .toList();
    final missingNames = suggestion.missingIngredients
        .map(_ingredientName)
        .toList();

    return RecipeCardModel(
      recipeId: recipe.recipeId,
      name: recipe.title,
      timeLabel: _timeLabel(recipe.cookingTimeMinutes),
      difficulty: _diff(recipe.difficulty),
      mealTime: _meal(recipe.mealType),
      matchType: missing <= 0 ? MatchType.full : MatchType.partial,
      availableIngredients: available,
      totalIngredients: total,
      missingCount: missing,
      expiringCount: 0,
      isExpiring: false,
      availableNames: availableNames,
      missingNames: missingNames,
      instructions: recipe.instructions,
    );
  }
}
