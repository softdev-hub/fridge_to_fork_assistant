import 'package:flutter/material.dart';
import '../common/bottomNavigation.dart';
import 'components/plan_tab_bar.dart';
import 'components/plan_models.dart';
import 'components/day_detail_meal_card.dart';
import 'components/missing_ingredients.dart';

class DayDetailView extends StatefulWidget {
  final DayPlan dayPlan;
  final DateTime selectedDate;

  const DayDetailView({
    Key? key,
    required this.dayPlan,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<DayDetailView> createState() => _DayDetailViewState();
}

class _DayDetailViewState extends State<DayDetailView> {
  int _selectedTabIndex = 0; // 0: Lịch tuần, 1: Danh sách mua sắm

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0, // hoặc 8 nếu muốn cách nhẹ
        centerTitle: false,
        title: const Text(
          'Thực đơn ngày',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tab bar
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

            // Content
            if (_selectedTabIndex == 0)
              _buildDayPlanContent()
            else
              _buildShoppingListContent(),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 3,
        onTap: (index) {
          // Handle bottom navigation tap
        },
      ),
    );
  }

  Widget _buildDayPlanContent() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            _buildDateHeader(),
            const SizedBox(height: 24),

            // Meal cards
            _buildMealCard(MealType.breakfast),
            const SizedBox(height: 12),
            _buildMealCard(MealType.lunch),
            const SizedBox(height: 12),
            _buildMealCard(MealType.dinner),
            const SizedBox(height: 24),

            // Missing ingredients section
            const MissingIngredientsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    final isToday = _isSameDay(widget.selectedDate, DateTime.now());
    final dayName = _getDayName(widget.selectedDate.weekday);
    final dateStr =
        '${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}';

    return Text(
      isToday ? 'Hôm nay, $dayName $dateStr' : '$dayName, $dateStr',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0F172A),
      ),
    );
  }

  Widget _buildMealCard(MealType mealType) {
    final mealSlot = widget.dayPlan.slots[mealType]!;
    return DayDetailMealCard(
      mealType: mealType,
      meal: mealSlot.meal,
      onTap: () {
        // TODO: Handle meal tap
      },
    );
  }

  Widget _buildShoppingListContent() {
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

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'T2';
      case 2:
        return 'T3';
      case 3:
        return 'T4';
      case 4:
        return 'T5';
      case 5:
        return 'T6';
      case 6:
        return 'T7';
      case 7:
        return 'CN';
      default:
        return 'T2';
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
