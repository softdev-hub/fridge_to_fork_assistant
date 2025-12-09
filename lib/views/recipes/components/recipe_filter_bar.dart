// lib/recipes/components/recipe_filter_bar.dart

import 'package:flutter/material.dart';

class RecipeFilterBar extends StatefulWidget {
  const RecipeFilterBar({Key? key}) : super(key: key);

  @override
  State<RecipeFilterBar> createState() => _RecipeFilterBarState();
}

class _RecipeFilterBarState extends State<RecipeFilterBar> {
  int _selectedIndex = 1; // Mặc định chọn "Sữa"

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            label: 'Thời gian',
            icon: Icons.access_time,
            index: 0,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(label: 'Sữa', icon: Icons.restaurant, index: 1),
          const SizedBox(width: 8),
          _buildFilterChip(label: 'Ẩm thực', icon: Icons.public, index: 2),
          const SizedBox(width: 8),
          // Tune/filter icon button to the right of the chips
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.tune, size: 18, color: Color(0xFF64748B)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required int index,
  }) {
    final bool isSelected = index == _selectedIndex;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        // TODO: handle filter change
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF22C55E) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF22C55E)
                : const Color(0xFFE2E8F0),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF16A34A).withOpacity(0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
