import 'package:flutter/material.dart';
import '../views/recipes/recipe_matching_view.dart';

class NavigationUtils {
  /// Navigate to recipe matching view with specific ingredient filter
  static void navigateToRecipesWithIngredient(
    BuildContext context, 
    String ingredientName,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeMatchingView(
          initialIngredientFilter: ingredientName,
        ),
      ),
    );
  }

  /// Navigate to recipe matching view without any filters
  static void navigateToRecipes(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RecipeMatchingView(),
      ),
    );
  }
}