// lib/recipes/components/recipe_card_item.dart

import 'package:flutter/material.dart';
import 'recipe_card_list.dart';
import '../recipe_detail_view.dart';

class RecipeCardItem extends StatelessWidget {
  final Recipe recipe;

  const RecipeCardItem({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => RecipeDetailView(recipe: recipe)),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: recipe.isExpiring ? const Color(0xFFFEFBF5) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: recipe.isExpiring
                ? const Color(0xFFF59E0B).withOpacity(0.8)
                : const Color(0xFFEEF0F4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF101828).withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            if (recipe.isExpiring)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThumbnail(),
                const SizedBox(width: 12),
                Expanded(child: _buildBody()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        border: Border.all(color: const Color(0xFFEEF0F4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image, size: 48, color: Color(0xFF9CA3AF)),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recipe.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        _buildMetaRow(),
        const SizedBox(height: 8),
        _buildMatchRow(),
      ],
    );
  }

  Widget _buildMetaRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _buildPill(icon: '⏱', label: recipe.timeLabel, type: PillType.time),
            _buildPill(
              icon: _getDifficultyIcon(),
              label: _getDifficultyLabel(),
              type: _getDifficultyPillType(),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _buildPill(
              icon: _getMealIcon(),
              label: _getMealLabel(),
              type: PillType.meal,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPill({
    required String icon,
    required String label,
    required PillType type,
  }) {
    Color bgColor;
    Color borderColor;
    Color textColor;

    switch (type) {
      case PillType.time:
      case PillType.meal:
        bgColor = const Color(0xFFF8FAFC);
        borderColor = const Color(0xFFEEF0F4);
        textColor = const Color(0xFF334155);
        break;
      case PillType.difficultyEasy:
        bgColor = const Color(0xFF10B981).withOpacity(0.1);
        borderColor = const Color(0xFF10B981).withOpacity(0.25);
        textColor = const Color(0xFF065F46);
        break;
      case PillType.difficultyMedium:
        bgColor = const Color(0xFF3B82F6).withOpacity(0.1);
        borderColor = const Color(0xFF3B82F6).withOpacity(0.25);
        textColor = const Color(0xFF1E3A8A);
        break;
      case PillType.difficultyHard:
        bgColor = const Color(0xFFEF4444).withOpacity(0.1);
        borderColor = const Color(0xFFEF4444).withOpacity(0.25);
        textColor = const Color(0xFF7F1D1D);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 6),
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

  Widget _buildMatchRow() {
    final isFull = recipe.matchType == MatchType.full;
    final List<Widget> badges = [_buildMatchBadge(isFull: isFull)];

    if (recipe.missingCount != null) {
      badges.add(_buildMissingBadge());
    }
    if (recipe.expiringCount != null) {
      badges.add(_buildExpiryRow());
    }

    return Wrap(spacing: 8, runSpacing: 8, children: badges);
  }

  Widget _buildMatchBadge({required bool isFull}) {
    final label = isFull
        ? 'Đủ ${recipe.availableIngredients}/${recipe.totalIngredients} nguyên liệu'
        : 'Có ${recipe.availableIngredients}/${recipe.totalIngredients} nguyên liệu';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isFull
            ? const Color(0xFF10B981).withOpacity(0.1)
            : const Color(0xFF3B82F6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFull
              ? const Color(0xFF10B981).withOpacity(0.25)
              : const Color(0xFF3B82F6).withOpacity(0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(isFull ? '✅' : '🧩', style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isFull ? const Color(0xFF065F46) : const Color(0xFF1E3A8A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 6),
          Text(
            'Thiếu ${recipe.missingCount} nguyên liệu',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF92400E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚠', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 6),
          Text(
            'Dùng ${recipe.expiringCount} nguyên liệu sắp hết hạn',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF92400E),
            ),
          ),
        ],
      ),
    );
  }

  String _getDifficultyIcon() {
    switch (recipe.difficulty) {
      case RecipeDifficulty.easy:
        return '✨';
      case RecipeDifficulty.medium:
        return '⚡';
      case RecipeDifficulty.hard:
        return '🔥';
    }
  }

  String _getDifficultyLabel() {
    switch (recipe.difficulty) {
      case RecipeDifficulty.easy:
        return 'Dễ';
      case RecipeDifficulty.medium:
        return 'Trung bình';
      case RecipeDifficulty.hard:
        return 'Khó';
    }
  }

  PillType _getDifficultyPillType() {
    switch (recipe.difficulty) {
      case RecipeDifficulty.easy:
        return PillType.difficultyEasy;
      case RecipeDifficulty.medium:
        return PillType.difficultyMedium;
      case RecipeDifficulty.hard:
        return PillType.difficultyHard;
    }
  }

  String _getMealIcon() {
    switch (recipe.mealTime) {
      case RecipeMealTime.breakfast:
        return '🌅';
      case RecipeMealTime.lunch:
        return '🍱';
      case RecipeMealTime.dinner:
        return '🍽';
    }
  }

  String _getMealLabel() {
    switch (recipe.mealTime) {
      case RecipeMealTime.breakfast:
        return 'Bữa sáng';
      case RecipeMealTime.lunch:
        return 'Bữa trưa';
      case RecipeMealTime.dinner:
        return 'Bữa tối';
    }
  }
}

enum PillType { time, meal, difficultyEasy, difficultyMedium, difficultyHard }
