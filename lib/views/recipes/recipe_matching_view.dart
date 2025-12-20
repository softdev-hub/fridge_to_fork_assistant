import 'package:flutter/material.dart';
import 'components/recipe_matching_filter_bar.dart';
import 'components/recipe_card_list.dart';
import 'components/recipe_fab.dart';
import '../common/bottomNavigation.dart';
import '../home_view.dart';
import '../pantry/pantry_view.dart';
import '../plans/plan_view.dart';

class RecipeMatchingView extends StatelessWidget {
  const RecipeMatchingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 2,
        onTap: (index) => _onNavTap(context, index),
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
                    child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
          ),
      child: SafeArea(
        bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                      onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
                  const Center(
                    child: Text(
              'Gợi ý hôm nay',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
                      ),
              ),
            ),
            Positioned(
              right: 0,
              child: IconButton(
                icon: const Icon(
                        Icons.more_vert,
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
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: RecipeMatchingFilterBar(
                      selectedFilters: const ['time', 'meal', 'cuisine'],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: RecipeCardList(
                      recipes: dummyRecipes,
                      isTablet: false,
                      isDesktop: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(right: 24, bottom: 24, child: RecipeFAB()),
        ],
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    if (index == 2) return;

    Widget? target;
    switch (index) {
      case 0:
        target = const HomeView();
        break;
      case 1:
        target = const PantryView();
        break;
      case 3:
        target = const PlanView();
        break;
    }

    if (target != null) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => target!));
    }
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
