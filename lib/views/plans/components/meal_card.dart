import 'package:flutter/material.dart';
import 'plan_models.dart';

class MealCard extends StatelessWidget {
  final MealType mealType;
  final Meal? meal;
  final VoidCallback? onTap;

  const MealCard({Key? key, required this.mealType, this.meal, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = meal == null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.add, size: 20, color: Color(0xFF94A3B8)),
        ),
      ),
    );
  }

  Widget _buildMealContent() {
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
                meal!.imageUrl,
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
            meal!.name,
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
