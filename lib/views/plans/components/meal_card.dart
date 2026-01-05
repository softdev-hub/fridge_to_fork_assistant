import 'package:flutter/material.dart';
import 'plan_models.dart';

class MealCard extends StatelessWidget {
  final MealType mealType;
  final List<Meal> meals; // có thể rỗng hoặc nhiều món
  final VoidCallback? onTap;
  final Function(Meal)? onRemoveMeal; // Thêm callback để xoá món

  const MealCard({
    Key? key,
    required this.mealType,
    this.meals = const [],
    this.onTap,
    this.onRemoveMeal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = meals.isEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Center(
              child: Text(
                mealType.label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: isEmpty ? _buildEmptyContent() : _buildMealContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContent() {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 56, // ô vuông
        height: 56,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9), // nền xám nhạt
            borderRadius: BorderRadius.circular(10), // bo tròn
          ),
          child: const Center(
            child: Icon(
              Icons.add,
              size: 20,
              color: Color(0xFF94A3B8), // màu xám icon +
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealContent() {
    final Meal firstMeal = meals.first;
    final int extraCount = meals.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              child: Image.network(
                firstMeal.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFF1F5F9),
                  child: const Icon(Icons.restaurant, size: 18),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          flex: 1,
          child: Text(
            extraCount > 0 ? '${firstMeal.name} +$extraCount' : firstMeal.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}
