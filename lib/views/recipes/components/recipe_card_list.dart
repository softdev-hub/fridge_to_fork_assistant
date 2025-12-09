// lib/recipes/components/recipe_card_list.dart

import 'package:flutter/material.dart';
import 'recipe_card_item.dart';

enum RecipeDifficulty { easy, medium }

enum RecipeMealTime { breakfast, dinner }

enum RecipeStatusType {
  success, // xanh lá
  info, // xanh dương
  warning, // cam
}

class RecipeStatusChipData {
  final String label;
  final RecipeStatusType type;

  RecipeStatusChipData({required this.label, required this.type});
}

class Recipe {
  final String name;
  final String timeLabel;
  final RecipeDifficulty difficulty;
  final RecipeMealTime mealTime;
  final List<RecipeStatusChipData> statuses;

  Recipe({
    required this.name,
    required this.timeLabel,
    required this.difficulty,
    required this.mealTime,
    required this.statuses,
  });
}

// Dummy data mô phỏng theo UI
final List<Recipe> dummyRecipes = [
  Recipe(
    name: 'Sữa chua dẻo',
    timeLabel: '15 phút',
    difficulty: RecipeDifficulty.easy,
    mealTime: RecipeMealTime.dinner,
    statuses: [
      RecipeStatusChipData(
        label: 'Đủ 6/6 nguyên liệu',
        type: RecipeStatusType.success,
      ),
      RecipeStatusChipData(
        label: 'Dùng 2 nguyên liệu sắp hết hạn',
        type: RecipeStatusType.warning,
      ),
    ],
  ),
  Recipe(
    name: 'Panna Cotta',
    timeLabel: '20 phút',
    difficulty: RecipeDifficulty.medium,
    mealTime: RecipeMealTime.breakfast,
    statuses: [
      RecipeStatusChipData(
        label: 'Có 5/6 nguyên liệu',
        type: RecipeStatusType.info,
      ),
      RecipeStatusChipData(
        label: 'Thiếu 1 nguyên liệu',
        type: RecipeStatusType.warning,
      ),
    ],
  ),
  Recipe(
    name: 'Sữa trứng bí đỏ',
    timeLabel: '20 phút',
    difficulty: RecipeDifficulty.medium,
    mealTime: RecipeMealTime.breakfast,
    statuses: [
      RecipeStatusChipData(
        label: 'Có 5/6 nguyên liệu',
        type: RecipeStatusType.info,
      ),
      RecipeStatusChipData(
        label: 'Thiếu 1 nguyên liệu',
        type: RecipeStatusType.warning,
      ),
    ],
  ),
  Recipe(
    name: 'Bánh mochi kem sốt',
    timeLabel: '20 phút',
    difficulty: RecipeDifficulty.medium,
    mealTime: RecipeMealTime.breakfast,
    statuses: [
      RecipeStatusChipData(
        label: 'Có 5/6 nguyên liệu',
        type: RecipeStatusType.info,
      ),
      RecipeStatusChipData(
        label: 'Thiếu 1 nguyên liệu',
        type: RecipeStatusType.warning,
      ),
    ],
  ),
];

class RecipeCardList extends StatelessWidget {
  final List<Recipe> recipes;

  const RecipeCardList({Key? key, required this.recipes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: recipes.length,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return RecipeCardItem(recipe: recipe);
      },
    );
  }
}
