import 'package:flutter/foundation.dart';
import '../controllers/recipe_suggestion_filters.dart';
import '../views/recipes/components/recipe_card_list.dart';
import '../views/plans/components/plan_models.dart';

/// Service để share recipe data giữa các tabs
/// Singleton pattern để duy trì state xuyên suốt app
class SharedRecipeService with ChangeNotifier {
  static final SharedRecipeService _instance = SharedRecipeService._internal();
  factory SharedRecipeService() => _instance;
  SharedRecipeService._internal();

  // Recipe được chọn để thêm vào plan
  RecipeCardModel? _selectedRecipe;

  // Flag để biết recipe được chọn từ recipe tab
  bool _isRecipeFromTab = false;

  // List recipes thật từ RecipeView để hiển thị trong bottom sheet
  List<RecipeCardModel> _availableRecipes = [];

  // Lưu filters đang được áp dụng ở Recipes tab để bottom sheet load cùng query.
  RecipeFilterOptions _lastAppliedFilters = const RecipeFilterOptions(
    timeKey: '',
    mealLabels: <String>{},
    cuisineLabels: <String>{},
  );

  // Map để lưu missing ingredients của từng recipe
  Map<int, List<String>> _recipeMissingIngredients = {};

  RecipeCardModel? get selectedRecipe => _selectedRecipe;
  bool get isRecipeFromTab => _isRecipeFromTab;
  List<RecipeCardModel> get availableRecipes => _availableRecipes;
  RecipeFilterOptions get lastAppliedFilters => _lastAppliedFilters;

  void setLastAppliedFilters(RecipeFilterOptions filters) {
    _lastAppliedFilters = filters;
    notifyListeners();
  }

  /// Đặt recipe được chọn từ recipe detail view
  void setSelectedRecipe(RecipeCardModel recipe, {bool fromTab = false}) {
    _selectedRecipe = recipe;
    _isRecipeFromTab = fromTab;

    // Lưu missing ingredients của recipe được chọn
    if (recipe.recipeId != null && recipe.missingNames.isNotEmpty) {
      _recipeMissingIngredients[recipe.recipeId!] = recipe.missingNames;
      print('⭐ Đặt selected recipe: ${recipe.name}');
      print('⭐ Missing ingredients: ${recipe.missingNames}');
    }

    notifyListeners();
  }

  /// Cập nhật danh sách recipes có sẵn từ RecipeView
  void updateAvailableRecipes(List<RecipeCardModel> recipes) {
    _availableRecipes = recipes;

    // Cập nhật missing ingredients cho từng recipe
    for (var recipe in recipes) {
      if (recipe.recipeId != null) {
        _recipeMissingIngredients[recipe.recipeId!] = recipe.missingNames;
        print(
          '🔄 Cập nhật missing ingredients cho recipe ${recipe.recipeId}: ${recipe.missingNames}',
        );
      }
    }
    print('📋 Tổng số recipes: ${recipes.length}');
    print('📋 Missing ingredients map: $_recipeMissingIngredients');
    notifyListeners();
  }

  /// Lấy missing ingredients của một recipe
  List<String> getMissingIngredients(int? recipeId) {
    if (recipeId == null) {
      print('⚠️ Recipe ID null');
      return [];
    }

    // Thử lấy từ map trước
    var ingredients = _recipeMissingIngredients[recipeId];

    // Nếu không có, thử tìm trong available recipes
    if ((ingredients == null || ingredients.isEmpty) &&
        _availableRecipes.isNotEmpty) {
      final matchingRecipe = _availableRecipes
          .where((r) => r.recipeId == recipeId)
          .firstOrNull;
      if (matchingRecipe != null && matchingRecipe.missingNames.isNotEmpty) {
        ingredients = matchingRecipe.missingNames;
        _recipeMissingIngredients[recipeId] = ingredients; // Cache lại
        print(
          '🔄 Lấy và cache missing ingredients từ available recipes cho $recipeId: $ingredients',
        );
      }
    }

    final result = ingredients ?? [];
    print('🔍 Lấy missing ingredients cho recipe $recipeId: $result');
    return result;
  }

  /// Xóa recipe đã chọn
  void clearSelectedRecipe() {
    _selectedRecipe = null;
    _isRecipeFromTab = false;
    notifyListeners();
  }

  /// Xóa toàn bộ dữ liệu
  void clearAll() {
    _selectedRecipe = null;
    _isRecipeFromTab = false;
    _availableRecipes.clear();
    _recipeMissingIngredients.clear();
    notifyListeners();
  }

  /// Chuyển đổi RecipeCardModel thành Meal object cho PlanView
  Meal recipeToMeal(RecipeCardModel recipe) {
    final meal = Meal(
      recipeId: recipe.recipeId,
      name: recipe.name,
      imageUrl:
          'https://images.unsplash.com/photo-1548943487-a2e4e43b4858?w=400', // fallback image
    );

    // Đảm bảo missing ingredients được lưu với recipeId
    if (recipe.recipeId != null && recipe.missingNames.isNotEmpty) {
      _recipeMissingIngredients[recipe.recipeId!] = recipe.missingNames;
      print(
        '💾 Lưu missing ingredients khi convert: ${recipe.recipeId} -> ${recipe.missingNames}',
      );
    }

    return meal;
  }

  /// Lấy danh sách meals từ available recipes
  List<Meal> getAvailableMeals() {
    return _availableRecipes.map((recipe) => recipeToMeal(recipe)).toList();
  }
}
