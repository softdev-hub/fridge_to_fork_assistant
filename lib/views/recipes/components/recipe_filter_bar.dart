// lib/recipes/components/recipe_filter_bar.dart

import 'package:flutter/material.dart';
import '../recipe_filter_view/recipe_filters_default_view.dart';

class RecipeFilterBar extends StatelessWidget {
  const RecipeFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    // One-row scrollable bar; button goes first; scrolls if overflow.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterButton(context),
          const SizedBox(width: 8),
          _buildFilterChip(label: 'Thời gian', icon: Icons.schedule),
          const SizedBox(width: 8),
          _buildFilterChip(label: 'Bữa ăn', icon: Icons.restaurant),
          const SizedBox(width: 8),
          _buildFilterChip(label: 'Ẩm thực', icon: Icons.public),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required String label, required IconData icon}) {
    return GestureDetector(
      onTap: () {
        // TODO: handle filter change
      },
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF6B7280)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return GestureDetector(
      onTap: () => RecipeFiltersDefaultView.show(context),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(17),
        ),
        child: const Icon(Icons.tune, size: 18, color: Color(0xFF6B7280)),
      ),
    );
  }
}
