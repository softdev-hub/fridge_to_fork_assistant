import 'package:flutter/material.dart';
import 'components/plan_tab_bar.dart';
import 'components/week_selector.dart';
import 'components/meal_grid.dart';
import 'components/plan_models.dart';
import 'components/calendar_dialog.dart';
import 'components/draggable_bottom_sheet.dart';
import 'day_detail_view.dart';

class PlanView extends StatefulWidget {
  const PlanView({super.key});

  @override
  State<PlanView> createState() => _PlanViewState();
}

class _PlanViewState extends State<PlanView> {
  int _selectedTabIndex = 0; // 0: Lịch tuần, 1: Danh sách mua sắm
  final WeekPlan _currentWeek = dummyWeekPlan;
  bool _showRecipeAddForm = false;
  final ScrollController _recipeScrollController = ScrollController();

  @override
  void dispose() {
    _recipeScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Kế hoạch và mua sắm',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0, //không tint thêm màu
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.ios_share, color: Colors.grey, size: 20),
              onPressed: () {
                setState(() {
                  _showRecipeAddForm = !_showRecipeAddForm;
                });
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.calendar_month_rounded,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CalendarDialog(
                      initialDate: DateTime.now(),
                      onDateSelected: (selectedDate) {
                        // TODO: Handle date selection and update week plan
                        Navigator.of(context).pop();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
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
                    _showRecipeAddForm = false;
                  });
                },
              ),
            ),

            // Nội dung theo tab
            Expanded(
              child: _selectedTabIndex == 0
                  ? Column(
                      children: [
                        Expanded(child: _buildWeekPlanContent()),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: _showRecipeAddForm
                              ? Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(24),
                                      topRight: Radius.circular(24),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 16,
                                        offset: const Offset(0, -4),
                                      ),
                                    ],
                                  ),
                                  child: DraggableBottomSheet(
                                    scrollController: _recipeScrollController,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    )
                  : _buildShoppingListPlaceholder(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekPlanContent() {
    return Column(
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

        // Meal grid - Fixed position, không scroll
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: MealGrid(
                weekPlan: _currentWeek,
                onDaySelected: (dayPlan, selectedDate) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DayDetailView(
                        dayPlan: dayPlan,
                        selectedDate: selectedDate,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShoppingListPlaceholder() {
    return const Center(
      child: Text(
        'Danh sách mua sắm\n(đang TODO)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8)),
      ),
    );
  }
}
