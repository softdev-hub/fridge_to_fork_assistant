// lib/recipes/components/recipe_fab.dart

import 'package:flutter/material.dart';

class RecipeFAB extends StatelessWidget {
  const RecipeFAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: const Color(0xFF4CAF50),
        borderRadius: BorderRadius.circular(22),
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.08),
        child: InkWell(
          onTap: () {
            final controller = PrimaryScrollController.of(context);
            controller.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            constraints: const BoxConstraints(minWidth: 60),
            child: const Icon(
              Icons.arrow_upward,
              size: 22,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
