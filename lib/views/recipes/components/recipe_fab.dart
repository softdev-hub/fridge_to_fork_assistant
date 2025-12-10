// lib/recipes/components/recipe_fab.dart

import 'package:flutter/material.dart';

class RecipeFAB extends StatelessWidget {
  const RecipeFAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isTablet = maxWidth >= 768;
        final containerMaxWidth = isTablet ? 768.0 : 412.0;
        final buttonWidth = (maxWidth > containerMaxWidth ? containerMaxWidth : maxWidth) - 48;
        
        return Center(
          child: Container(
            width: buttonWidth,
            height: 56,
            constraints: const BoxConstraints(minWidth: 160),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.refresh,
                        size: 24,
                        color: Colors.white,
                      ),
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
          ),
        );
      },
    );
  }
}

