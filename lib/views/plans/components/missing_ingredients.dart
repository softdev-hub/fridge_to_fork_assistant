import 'package:flutter/material.dart';

class MissingIngredientsSection extends StatelessWidget {
  const MissingIngredientsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nguyên liệu thiếu',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ingredients list
              ..._buildIngredientsList(),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildIngredientsList() {
    final ingredients = [
      '200g thịt bò',
      '1 củ hành tây',
      '1 quả ớt chuông',
      'Gia vị: tiêu, tỏi',
      '2 nhánh hành lá',
    ];

    return ingredients.map((ingredient) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bullet point
            Container(
              margin: const EdgeInsets.only(top: 6, right: 8),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF6B7280),
                shape: BoxShape.circle,
              ),
            ),

            // Ingredient text
            Expanded(
              child: Text(
                ingredient,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
