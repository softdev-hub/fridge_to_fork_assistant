import 'package:flutter/material.dart';
import '../common/bottom_navigation.dart';
import 'components/plan_tab_bar.dart';
import 'components/week_selector.dart';
import 'components/meal_grid.dart';
import 'components/plan_models.dart';

class PlanView extends StatefulWidget {
  const PlanView({super.key});

  @override
  State<PlanView> createState() => _PlanViewState();
}

class _PlanViewState extends State<PlanView> {
  int _selectedTabIndex = 0; // 0: Lịch tuần, 1: Danh sách mua sắm
  final WeekPlan _currentWeek = dummyWeekPlan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kế hoạch và mua sắm'), elevation: 0),
      body: SafeArea(
        child: Column(
          children: [
            // Segmented control
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: PlanTabBar(
                selectedIndex: _selectedTabIndex,
                onTabSelected: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
              ),
            ),

            // Nội dung theo tab
            if (_selectedTabIndex == 0)
              _buildWeekPlanContent()
            else
              _buildShoppingListPlaceholder(),
          ],
        ),
      ),
      // Tab "Kế hoạch" là index 3 (0-based)
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 3,
        onTap: (index) {
          // Handle bottom navigation tap
        },
      ),
    );
  }

  Widget _buildWeekPlanContent() {
    return Expanded(
      child: Column(
        children: [
          // Week selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: WeekSelector(
              label: _currentWeek.label,
              onPrevious: () {
                // TODO: handle previous week
              },
              onNext: () {
                // TODO: handle next week
              },
            ),
          ),
          const SizedBox(height: 16),

          // Meal grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MealGrid(weekPlan: _currentWeek),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingListPlaceholder() {
    return const Expanded(
      child: Center(
        child: Text(
          'Danh sách mua sắm\n(đang TODO)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8)),
        ),
      ),
    );
  }
}
