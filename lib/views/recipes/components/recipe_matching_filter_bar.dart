// lib/recipes/components/recipe_matching_filter_bar.dart

import 'package:flutter/material.dart';
import '../recipe_filter_view/recipe_filters_default_view.dart';

class RecipeMatchingFilterBar extends StatelessWidget {
  final List<String> selectedFilters;

  const RecipeMatchingFilterBar({Key? key, this.selectedFilters = const []})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // One-row scrollable bar; button first; scrolls if overflow.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterButton(context),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Dưới 20 phút',
            icon: Icons.schedule,
            isSelected: selectedFilters.contains('time'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Bữa tối',
            icon: Icons.restaurant,
            isSelected: selectedFilters.contains('meal'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Ẩm thực Á',
            icon: Icons.public,
            isSelected: selectedFilters.contains('cuisine'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        // TODO: handle filter change
      },
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        RecipeFiltersDefaultView.show(context);
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.tune, size: 18, color: Color(0xFF6B7280)),
      ),
    );
  }
}
