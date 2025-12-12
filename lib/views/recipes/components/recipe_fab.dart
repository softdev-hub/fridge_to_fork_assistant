// lib/recipes/components/recipe_fab.dart

import 'package:flutter/material.dart';

class RecipeFAB extends StatelessWidget {
  const RecipeFAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: const Color(0xFF4CAF50),
        borderRadius: BorderRadius.circular(28),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: () {
            // TODO: refresh recipe suggestions
          },
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            constraints: const BoxConstraints(minWidth: 160),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.refresh, size: 24, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Gợi ý lại',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
