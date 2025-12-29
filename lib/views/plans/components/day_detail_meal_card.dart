import 'package:flutter/material.dart';
import 'plan_models.dart';

class DayDetailMealCard extends StatelessWidget {
  final MealType? mealType; // Made nullable to hide label for additional meals
  final Meal? meal;
  final VoidCallback? onTap;

  const DayDetailMealCard({
    Key? key,
    this.mealType, // Made optional
    this.meal,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = meal == null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          // Meal image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFF3F4F6),
            ),
            child: isEmpty
                ? const Icon(Icons.add, size: 24, color: Color(0xFF9CA3AF))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      meal!.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF3F4F6),
                        child: const Icon(
                          Icons.restaurant,
                          size: 24,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // Meal info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal type label (only show for first meal in slot)
                if (mealType != null) ...[
                  Text(
                    _getMealTypeLabel(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],

                // Meal name
                Text(
                  isEmpty ? 'Thêm món ăn' : meal!.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isEmpty
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),

          // Delete icon
          const Icon(Icons.delete_outline, size: 20, color: Color(0xFFD1D5DB)),
        ],
      ),
    );
  }

  String _getMealTypeLabel() {
    if (mealType == null) return '';
    switch (mealType!) {
      case MealType.breakfast:
        return 'Bữa sáng';
      case MealType.lunch:
        return 'Bữa trưa';
      case MealType.dinner:
        return 'Bữa tối';
    }
  }
}
