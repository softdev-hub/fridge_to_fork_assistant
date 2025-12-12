import 'package:flutter/material.dart';
import 'components/recipe_card_list.dart';

class RecipeDetailView extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailView({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        title: Text(
          recipe.name,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEEF0F4)),
              ),
              child: const Center(
                child: Icon(Icons.image, size: 64, color: Color(0xFF9CA3AF)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              recipe.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Thời gian: ${recipe.timeLabel}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Nguyên liệu sẵn có: ${recipe.availableIngredients}/${recipe.totalIngredients}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4B5563),
              ),
            ),
            if (recipe.missingCount != null) ...[
              const SizedBox(height: 8),
              Text(
                'Thiếu: ${recipe.missingCount}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
            if (recipe.expiringCount != null) ...[
              const SizedBox(height: 8),
              Text(
                'Sắp hết hạn: ${recipe.expiringCount}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: action to start cooking or add to plan
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Bắt đầu nấu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
