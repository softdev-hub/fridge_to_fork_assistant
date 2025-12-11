import 'package:flutter/material.dart';
import 'components/recipe_matching_filter_bar.dart';
import 'components/recipe_card_list.dart';
import 'components/recipe_fab.dart';

class RecipeMatchingView extends StatelessWidget {
  const RecipeMatchingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 768;
          final isDesktop = constraints.maxWidth >= 1024;
          final horizontalPadding = isTablet ? 32.0 : 24.0;
          final bottomPadding = 80.0; // Space for FAB

          return Stack(
            children: [
              Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: Container(
                      color: const Color(0xFFF8F9FA),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          bottomPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 20),
                            RecipeMatchingFilterBar(
                              selectedFilters: ['time', 'meal', 'cuisine'],
                            ),
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
                  ),
                ],
              ),
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: const RecipeFAB(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 0,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  size: 24,
                  color: Color(0xFF1F2937),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            const Text(
              'Gợi ý hôm nay',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            Positioned(
              right: 0,
              child: IconButton(
                icon: const Icon(
                  Icons.settings,
                  size: 24,
                  color: Color(0xFF6B7280),
                ),
                onPressed: () {
                  // TODO: open settings
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
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
          'Tìm thấy 12 công thức',
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

