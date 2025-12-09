// lib/recipes/components/recipe_list_screen.dart

import 'package:flutter/material.dart';
import 'recipe_filter_bar.dart';
import 'recipe_card_list.dart';

class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // (Title shown in AppBar; removed duplicate in-body title)
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: RecipeFilterBar(),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Tìm thấy 24 công thức',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF000000),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: RecipeCardList(recipes: dummyRecipes),
            ),
          ),
        ],
      ),
    );
  }
}
