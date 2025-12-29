import 'enums.dart';
import 'ingredient.dart';
import 'meal_plan.dart';
import 'recipe.dart';

class ShoppingListItem {
  final int? itemId; // item_id (bigserial PK)
  final int listId; // list_id (bigint FK -> weekly_shopping_lists.list_id)
  final int?
  ingredientId; // ingredient_id (bigint FK -> ingredients.ingredient_id)
  final int? mealPlanId; // meal_plan_id (bigint FK -> meal_plans.meal_plan_id)
  final String? sourceName; // source_name (text)
  final double quantity; // quantity (numeric)
  final UnitEnum unit; // unit (unit_enum)
  final bool isPurchased; // is_purchased (boolean)
  final int?
  sourceRecipeId; // source_recipe_id (bigint FK -> recipes.recipe_id)
  final DateTime? createdAt; // created_at (timestamptz)

  // Optional joined data
  final Ingredient? ingredient; // joined from ingredients
  final MealPlan? mealPlan; // joined from meal_plans
  final Recipe? recipe; // joined from recipes

  ShoppingListItem({
    this.itemId,
    required this.listId,
    this.ingredientId,
    this.mealPlanId,
    this.sourceName,
    required this.quantity,
    required this.unit,
    this.isPurchased = false,
    this.sourceRecipeId,
    this.createdAt,
    this.ingredient,
    this.mealPlan,
    this.recipe,
  });

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      itemId: json['item_id'] as int?,
      listId: json['list_id'] as int,
      ingredientId: json['ingredient_id'] as int?,
      mealPlanId: json['meal_plan_id'] as int?,
      sourceName: json['source_name'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      unit: UnitEnum.fromDbValue(json['unit'] as String),
      isPurchased: json['is_purchased'] as bool? ?? false,
      sourceRecipeId: json['source_recipe_id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      ingredient: json['ingredients'] != null
          ? Ingredient.fromJson(json['ingredients'] as Map<String, dynamic>)
          : null,
      mealPlan: json['meal_plans'] != null
          ? MealPlan.fromJson(json['meal_plans'] as Map<String, dynamic>)
          : null,
      recipe: json['recipes'] != null
          ? Recipe.fromJson(json['recipes'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Full JSON (bao gồm PK) – dùng cho hiển thị/debug.
  Map<String, dynamic> toJson() {
    return {
      if (itemId != null) 'item_id': itemId,
      'list_id': listId,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (mealPlanId != null) 'meal_plan_id': mealPlanId,
      if (sourceName != null) 'source_name': sourceName,
      'quantity': quantity,
      'unit': unit.toDbValue(),
      'is_purchased': isPurchased,
      if (sourceRecipeId != null) 'source_recipe_id': sourceRecipeId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  /// JSON để insert/upsert vào Supabase (DB tự set created_at, PK).
  Map<String, dynamic> toInsertJson() {
    return {
      'list_id': listId,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (mealPlanId != null) 'meal_plan_id': mealPlanId,
      if (sourceName != null) 'source_name': sourceName,
      'quantity': quantity,
      'unit': unit.toDbValue(),
      'is_purchased': isPurchased,
      if (sourceRecipeId != null) 'source_recipe_id': sourceRecipeId,
    };
  }

  /// JSON để update record hiện có (không đổi list_id/PK).
  Map<String, dynamic> toUpdateJson() {
    return {
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (mealPlanId != null) 'meal_plan_id': mealPlanId,
      if (sourceName != null) 'source_name': sourceName,
      'quantity': quantity,
      'unit': unit.toDbValue(),
      'is_purchased': isPurchased,
      if (sourceRecipeId != null) 'source_recipe_id': sourceRecipeId,
    };
  }

  ShoppingListItem copyWith({
    int? itemId,
    int? listId,
    int? ingredientId,
    int? mealPlanId,
    String? sourceName,
    double? quantity,
    UnitEnum? unit,
    bool? isPurchased,
    int? sourceRecipeId,
    DateTime? createdAt,
    Ingredient? ingredient,
    MealPlan? mealPlan,
    Recipe? recipe,
  }) {
    return ShoppingListItem(
      itemId: itemId ?? this.itemId,
      listId: listId ?? this.listId,
      ingredientId: ingredientId ?? this.ingredientId,
      mealPlanId: mealPlanId ?? this.mealPlanId,
      sourceName: sourceName ?? this.sourceName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isPurchased: isPurchased ?? this.isPurchased,
      sourceRecipeId: sourceRecipeId ?? this.sourceRecipeId,
      createdAt: createdAt ?? this.createdAt,
      ingredient: ingredient ?? this.ingredient,
      mealPlan: mealPlan ?? this.mealPlan,
      recipe: recipe ?? this.recipe,
    );
  }

  @override
  String toString() =>
      'ShoppingListItem(itemId: $itemId, listId: $listId, ingredientId: $ingredientId, quantity: $quantity, unit: $unit, isPurchased: $isPurchased)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShoppingListItem && other.itemId == itemId;
  }

  @override
  int get hashCode => itemId.hashCode;
}
