import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/enums.dart';
import '../models/recipe_ingredient.dart';
import '../models/shopping_list_items.dart';
import '../models/weekly_shopping_lists.dart';
import '../models/pantry_item.dart';
import '../models/ingredient.dart';

/// Service để xử lý shopping list operations
class ShoppingListService {
  ShoppingListService._();

  static final ShoppingListService instance = ShoppingListService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Lấy hoặc tạo weekly shopping list cho tuần hiện tại
  Future<WeeklyShoppingList> getOrCreateWeeklyList({
    required String profileId,
    required DateTime weekStart,
  }) async {
    final weekStartStr = weekStart.toIso8601String().split('T')[0];

    // Tìm list hiện có
    final existing = await _supabase
        .from('weekly_shopping_lists')
        .select()
        .eq('profile_id', profileId)
        .eq('week_start', weekStartStr)
        .maybeSingle();

    if (existing != null) {
      return WeeklyShoppingList.fromJson(existing);
    }

    // Tạo mới nếu chưa có
    final newList = WeeklyShoppingList(
      profileId: profileId,
      weekStart: weekStart,
      title: 'Tuần ${_getWeekNumber(weekStart)}',
    );

    final response = await _supabase
        .from('weekly_shopping_lists')
        .insert(newList.toInsertJson())
        .select()
        .single();

    return WeeklyShoppingList.fromJson(response);
  }

  /// Lấy tất cả pantry items của user để kiểm tra ingredients hiện có
  Future<List<PantryItem>> getUserPantryItems(String profileId) async {
    final response = await _supabase
        .from('pantry_items')
        .select('''
          *,
          ingredient:ingredients(*)
        ''')
        .eq('profile_id', profileId)
        .isFilter('deleted_at', null);

    return (response as List<dynamic>)
        .map((e) => PantryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Lấy recipe ingredients của một recipe
  Future<List<RecipeIngredient>> getRecipeIngredients(int recipeId) async {
    final response = await _supabase
        .from('recipe_ingredients')
        .select('''
          *,
          ingredient:ingredients(*)
        ''')
        .eq('recipe_id', recipeId);

    final dbIngredients = (response as List<dynamic>)
        .map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
        .toList();

    // Nếu không có trong database, tạo dummy ingredients dựa trên recipeId
    if (dbIngredients.isEmpty) {
      return _createDummyRecipeIngredients(recipeId);
    }

    return dbIngredients;
  }

  // Tạo dummy recipe ingredients cho testing dựa trên recipeId
  List<RecipeIngredient> _createDummyRecipeIngredients(int recipeId) {
    final ingredientsMap = {
      1: ['Gà', 'Nước cốt dừa', 'Lá cà ri'], // Cà ri gà
      2: ['Bánh mì', 'Chả cá', 'Rau thơm'], // Bánh mì chả cá
      3: ['Cá', 'Thì là', 'Mắm tôm'], // Chả cá Lã Vọng
      4: ['Bún', 'Cá', 'Cà chua'], // Bún cá Hải Phòng
    };

    final ingredients = ingredientsMap[recipeId] ?? ['Nguyên liệu mặc định'];

    return ingredients.asMap().entries.map((entry) {
      final index = entry.key;
      final name = entry.value;

      return RecipeIngredient(
        recipeId: recipeId,
        ingredientId: index + 1,
        quantity: 100.0 + (index * 50), // Dummy quantities
        unit: UnitEnum.g,
        ingredient: Ingredient(
          ingredientId: index + 1,
          name: name,
          category: 'proteins',
        ),
      );
    }).toList();
  }

  /// Kiểm tra missing ingredients và thêm vào shopping list
  Future<void> addMissingIngredientsToShoppingList({
    required String profileId,
    required int recipeId,
    required DateTime weekStart,
    int? mealPlanId,
  }) async {
    try {
      // 1. Lấy hoặc tạo weekly shopping list
      final weeklyList = await getOrCreateWeeklyList(
        profileId: profileId,
        weekStart: weekStart,
      );

      // 2. Lấy recipe ingredients
      final recipeIngredients = await getRecipeIngredients(recipeId);

      // 3. Lấy pantry items của user
      final pantryItems = await getUserPantryItems(profileId);

      // 4. Tìm missing ingredients
      final missingIngredients = <RecipeIngredient>[];

      for (final recipeIngredient in recipeIngredients) {
        final ingredientId = recipeIngredient.ingredientId;

        // Kiểm tra xem có trong pantry không
        final pantryItem = pantryItems.firstWhere(
          (item) => item.ingredientId == ingredientId,
          orElse: () => PantryItem(
            profileId: profileId,
            ingredientId: 0,
            quantity: 0,
            unit: UnitEnum.g,
            purchaseDate: DateTime.now(),
            expiryDate: DateTime.now(),
          ),
        );

        // Nếu không có trong pantry hoặc không đủ số lượng
        if (pantryItem.ingredientId == 0 ||
            !_hasEnoughQuantity(pantryItem, recipeIngredient)) {
          missingIngredients.add(recipeIngredient);
        }
      }

      // 5. Thêm missing ingredients vào shopping list
      for (final missingIngredient in missingIngredients) {
        await _addOrUpdateShoppingListItem(
          listId: weeklyList.listId!,
          ingredient: missingIngredient,
          mealPlanId: mealPlanId,
          sourceRecipeId: recipeId,
        );
      }
    } catch (e) {
      debugPrint('Error adding missing ingredients to shopping list: $e');
    }
  }

  /// Kiểm tra xem pantry item có đủ số lượng cho recipe không
  bool _hasEnoughQuantity(
    PantryItem pantryItem,
    RecipeIngredient recipeIngredient,
  ) {
    // Simplified check - in production, you might want to convert units
    if (pantryItem.unit != recipeIngredient.unit) {
      return false; // Khác unit thì coi như không đủ để đơn giản
    }

    return pantryItem.quantity >= recipeIngredient.quantity;
  }

  /// Thêm hoặc cập nhật shopping list item
  Future<void> _addOrUpdateShoppingListItem({
    required int listId,
    required RecipeIngredient ingredient,
    int? mealPlanId,
    int? sourceRecipeId,
  }) async {
    // Kiểm tra xem đã có item này trong shopping list chưa
    final existingItems = await _supabase
        .from('shopping_list_items')
        .select()
        .eq('list_id', listId)
        .eq('ingredient_id', ingredient.ingredientId)
        .eq('source_recipe_id', sourceRecipeId ?? 0);

    if (existingItems.isNotEmpty) {
      // Cập nhật quantity nếu đã có
      final existingItem = ShoppingListItem.fromJson(existingItems.first);

      final newQuantity = existingItem.quantity + ingredient.quantity;

      await _supabase
          .from('shopping_list_items')
          .update({'quantity': newQuantity})
          .eq('item_id', existingItem.itemId!);
    } else {
      // Tạo mới nếu chưa có
      final newItem = ShoppingListItem(
        listId: listId,
        ingredientId: ingredient.ingredientId,
        quantity: ingredient.quantity,
        unit: ingredient.unit,
        mealPlanId: mealPlanId,
        sourceRecipeId: sourceRecipeId,
      );

      await _supabase
          .from('shopping_list_items')
          .insert(newItem.toInsertJson());
    }
  }

  /// Helper để tính week number
  int _getWeekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return (dayOfYear / 7).ceil();
  }
}
