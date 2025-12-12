import 'package:flutter/material.dart';
import 'recipe_filter_bar.dart';
import 'recipe_card_list.dart';

class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 768;
        final isDesktop = constraints.maxWidth >= 1024;

        final horizontalPadding = isTablet ? 32.0 : 24.0;

        return Container(
          color: const Color(0xFFF8F9FA),
          child: SafeArea(
            bottom: true,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                0, // không chừa chỗ, để FAB đè lên card
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const RecipeFilterBar(),
                  const SizedBox(height: 20),
                  const _SummaryRow(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: RecipeCardList(
                      recipes: dummyRecipes,
                      isTablet: isTablet,
                      isDesktop: isDesktop,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Dùng kho hiện tại',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280),
          ),
        ),
        const Text(
          'Tìm thấy 24 công thức',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}
