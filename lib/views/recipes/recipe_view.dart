import 'package:flutter/material.dart';
import 'components/recipe_list_screen.dart';
import 'components/recipe_fab.dart';

class RecipeView extends StatelessWidget {
  const RecipeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Gợi ý món',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.more_vert,
                      size: 24,
                      color: Color(0xFF6B7280),
                    ),
                    onPressed: () {
                      // TODO: open more options
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          const SafeArea(top: false, child: RecipeListScreen()),
          Positioned(bottom: 80, left: 0, right: 0, child: const RecipeFAB()),
        ],
      ),
    );
  }
}
