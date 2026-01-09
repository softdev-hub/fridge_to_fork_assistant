// lib/recipes/components/recipe_card_list.dart

import 'package:flutter/material.dart';
import 'recipe_card_item.dart';

enum RecipeDifficulty { easy, medium, hard }

enum RecipeMealTime { breakfast, lunch, dinner }

enum MatchType { full, partial }

class RecipeCardModel {
  final int? recipeId;
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
  final List<String> availableNames;
  final List<String> missingNames;
  final String? instructions;
  final String? videoUrl;
  final String? imageUrl;

  RecipeCardModel({
    this.recipeId,
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
    this.availableNames = const [],
    this.missingNames = const [],
    this.instructions,
    this.videoUrl,
    this.imageUrl,
  });
}

class RecipeCardList extends StatelessWidget {
  final List<RecipeCardModel> recipes;
  final bool isTablet;
  final bool isDesktop;
  final ScrollPhysics? physics;

  const RecipeCardList({
    Key? key,
    required this.recipes,
    this.isTablet = false,
    this.isDesktop = false,
    this.physics,
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
        physics: physics,
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
        physics: physics,
      );
    } else {
      return ListView.separated(
        physics: physics ?? const BouncingScrollPhysics(),
        itemCount: recipes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return RecipeCardItem(recipe: recipes[index]);
        },
      );
    }
  }
}
