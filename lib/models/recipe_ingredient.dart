import 'enums.dart';
import 'ingredient.dart';

class RecipeIngredient {
  final int recipeId;
  final int ingredientId;
  final double quantity;
  final UnitEnum unit;

  // Optional joined ingredient
  final Ingredient? ingredient;

  const RecipeIngredient({
    required this.recipeId,
    required this.ingredientId,
    required this.quantity,
    required this.unit,
    this.ingredient,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      recipeId: json['recipe_id'] as int,
      ingredientId: json['ingredient_id'] as int,
      quantity: (json['quantity'] as num).toDouble(),
      unit: UnitEnum.fromDbValue(json['unit'] as String),
      ingredient: json['ingredients'] != null
          ? Ingredient.fromJson(json['ingredients'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipe_id': recipeId,
      'ingredient_id': ingredientId,
      'quantity': quantity,
      'unit': unit.toDbValue(),
    };
  }
}
