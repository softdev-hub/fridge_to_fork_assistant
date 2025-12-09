// lib/recipes/components/recipe_card_item.dart

import 'package:flutter/material.dart';
import 'recipe_card_list.dart';

class RecipeCardItem extends StatelessWidget {
  final Recipe recipe;

  const RecipeCardItem({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: open recipe detail
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildImagePlaceholder(),
            const SizedBox(width: 20),
            Expanded(child: _buildInfoSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 95,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.image_outlined,
        size: 40,
        color: Color(0xFF94A3B8),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recipe.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        _buildTimeAndDifficultyRow(),
        const SizedBox(height: 6),
        _buildMealTag(),
        const SizedBox(height: 6),
        _buildStatusChips(),
      ],
    );
  }

  Widget _buildTimeAndDifficultyRow() {
    return Row(
      children: [
        Icon(Icons.access_time, size: 14, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 4),
        Text(
          recipe.timeLabel,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        const SizedBox(width: 8),
        _DifficultyChip(difficulty: recipe.difficulty),
      ],
    );
  }

  Widget _buildMealTag() {
    final String label = recipe.mealTime == RecipeMealTime.breakfast
        ? 'Bữa sáng'
        : 'Bữa tối';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.restaurant_menu, size: 12, color: Color(0xFFFB923C)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF9A3412),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChips() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: recipe.statuses.map((status) {
        return _StatusChip(status: status);
      }).toList(),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final RecipeDifficulty difficulty;

  const _DifficultyChip({Key? key, required this.difficulty}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isEasy = difficulty == RecipeDifficulty.easy;
    final String label = isEasy ? 'Dễ' : 'Trung bình';

    final Color bgColor = isEasy
        ? const Color(0xFFE0F2FE)
        : const Color(0xFFE0E7FF);
    final Color textColor = isEasy
        ? const Color(0xFF0369A1)
        : const Color(0xFF3730A3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, size: 12, color: Color(0xFFF97316)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final RecipeStatusChipData status;

  const _StatusChip({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late Color bgColor;
    late Color textColor;
    late IconData icon;

    switch (status.type) {
      case RecipeStatusType.success:
        bgColor = const Color(0xFFE0FCE4);
        textColor = const Color(0xFF15803D);
        icon = Icons.check_circle;
        break;
      case RecipeStatusType.info:
        bgColor = const Color(0xFFE0ECFF);
        textColor = const Color(0xFF1D4ED8);
        icon = Icons.info_outline;
        break;
      case RecipeStatusType.warning:
        bgColor = const Color(0xFFFFF4E5);
        textColor = const Color(0xFFB45309);
        icon = Icons.warning_amber_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
