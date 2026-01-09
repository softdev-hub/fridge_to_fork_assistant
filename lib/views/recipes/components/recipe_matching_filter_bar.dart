// lib/recipes/components/recipe_matching_filter_bar.dart

import 'package:flutter/material.dart';
import '../recipe_filter_view/recipe_filters_default_view.dart';
import '../../../controllers/recipe_suggestion_filters.dart';

class RecipeMatchingFilterBar extends StatelessWidget {
  final RecipeFilterOptions filters;
  final ValueChanged<RecipeFilterOptions>? onApplied;

  const RecipeMatchingFilterBar({
    Key? key,
    this.filters = const RecipeFilterOptions(
      timeKey: '',
      mealLabels: <String>{},
      cuisineLabels: <String>{},
      ingredientLabels: <String>{},
    ),
    this.onApplied,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chips = _buildSelectedChips();

    // One-row scrollable bar; button first; scrolls if overflow.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterButton(context),
          const SizedBox(width: 8),
          ...chips,
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await RecipeFiltersDefaultView.show(
          context,
          initial: filters,
        );
        if (result != null && onApplied != null) {
          onApplied!(result);
        }
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

  List<Widget> _buildSelectedChips() {
    final widgets = <Widget>[];

    final timeLabel = _timeDisplay(filters.timeKey);
    if (timeLabel != null) {
      widgets.add(_chip(icon: Icons.schedule, label: timeLabel));
      widgets.add(const SizedBox(width: 8));
    }

    if (filters.mealLabels.isNotEmpty) {
      final mealText = filters.mealLabels.join(', ');
      widgets.add(_chip(icon: Icons.restaurant, label: mealText));
      widgets.add(const SizedBox(width: 8));
    }

    if (filters.cuisineLabels.isNotEmpty) {
      final cuisineText = filters.cuisineLabels.join(', ');
      widgets.add(_chip(icon: Icons.public, label: cuisineText));
      widgets.add(const SizedBox(width: 8));
    }

    if (filters.ingredientLabels.isNotEmpty) {
      final ingredientText =
          'Nguyên liệu: ${filters.ingredientLabels.join(', ')}';
      widgets.add(_chip(icon: Icons.eco, label: ingredientText));
      widgets.add(const SizedBox(width: 8));
    }

    // Nếu không có gì được chọn, hiển thị chip hint.
    if (widgets.isEmpty) {
      widgets.add(
        _chip(
          icon: Icons.filter_alt_outlined,
          label: 'Chưa chọn bộ lọc',
          isSelected: false,
        ),
      );
    } else {
      // bỏ spacer cuối cùng
      if (widgets.isNotEmpty && widgets.last is SizedBox) {
        widgets.removeLast();
      }
    }
    return widgets;
  }

  Widget _chip({
    required IconData icon,
    required String label,
    bool isSelected = true,
  }) {
    return Container(
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
    );
  }

  String? _timeDisplay(String key) {
    switch (key) {
      case 'under15':
        return 'Dưới 15 phút';
      case '15to30':
        return '15–30 phút';
      case 'over30':
        return 'Trên 30 phút';
      case 'none':
        return null;
      default:
        return null;
    }
  }
}
