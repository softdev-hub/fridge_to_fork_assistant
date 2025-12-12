// lib/recipes/components/recipe_card_list.dart

import 'package:flutter/material.dart';
import 'recipe_card_item.dart';

enum RecipeDifficulty { easy, medium, hard }

enum RecipeMealTime { breakfast, lunch, dinner }

enum MatchType { full, partial }

class Recipe {
  final String name;
  final String timeLabel;
  final RecipeDifficulty difficulty;
  final RecipeMealTime mealTime;
  final MatchType matchType;
  final int availableIngredients;
  final int totalIngredients;
  final int? missingCount;
  final int? expiringCount;
  final bool isExpiring;

  Recipe({
    required this.name,
    required this.timeLabel,
    required this.difficulty,
    required this.mealTime,
    required this.matchType,
    required this.availableIngredients,
    required this.totalIngredients,
    this.missingCount,
    this.expiringCount,
    this.isExpiring = false,
  });
}

// Dummy data mô phỏng theo HTML
final List<Recipe> dummyRecipes = [
  Recipe(
    name: 'Cà ri gà thơm lừng',
    timeLabel: '15 phút',
    difficulty: RecipeDifficulty.easy,
    mealTime: RecipeMealTime.dinner,
    matchType: MatchType.full,
    availableIngredients: 6,
    totalIngredients: 6,
    expiringCount: 2,
    isExpiring: true,
  ),
  Recipe(
    name: 'Bánh mì chả cá Nha Trang',
    timeLabel: '20 phút',
    difficulty: RecipeDifficulty.medium,
    mealTime: RecipeMealTime.dinner,
    matchType: MatchType.partial,
    availableIngredients: 5,
    totalIngredients: 6,
    missingCount: 1,
  ),
  Recipe(
    name: 'Chả cá Lã Vọng truyền thống',
    timeLabel: '15 phút',
    difficulty: RecipeDifficulty.hard,
    mealTime: RecipeMealTime.dinner,
    matchType: MatchType.partial,
    availableIngredients: 7,
    totalIngredients: 9,
    missingCount: 2,
  ),
  Recipe(
    name: 'Bún cá Hải Phòng truyền thống',
    timeLabel: '20 phút',
    difficulty: RecipeDifficulty.hard,
    mealTime: RecipeMealTime.dinner,
    matchType: MatchType.partial,
    availableIngredients: 7,
    totalIngredients: 9,
    missingCount: 2,
  ),
];

class RecipeCardList extends StatelessWidget {
  final List<Recipe> recipes;
  final bool isTablet;
  final bool isDesktop;

  const RecipeCardList({
    Key? key,
    required this.recipes,
    this.isTablet = false,
    this.isDesktop = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return RecipeCardItem(recipe: recipes[index]);
        },
      );
    } else if (isTablet) {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return RecipeCardItem(recipe: recipes[index]);
        },
      );
    } else {
      return ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: recipes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return RecipeCardItem(recipe: recipes[index]);
        },
      );
    }
  }
}
