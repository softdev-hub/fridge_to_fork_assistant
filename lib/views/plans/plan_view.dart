import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/enums.dart';
import '../../services/meal_plan_service.dart';
import '../../services/shopping_list_service.dart';
import 'components/calendar_dialog.dart';
import 'components/draggable_bottom_sheet.dart';
import 'components/meal_grid.dart';
import 'components/plan_models.dart';
import 'components/plan_tab_bar.dart';
import 'components/shopping_list.dart';
import 'components/week_selector.dart';
import 'day_detail_view.dart';

class PlanView extends StatefulWidget {
  const PlanView({super.key});

  @override
  State<PlanView> createState() => _PlanViewState();
}

class _PlanViewState extends State<PlanView> {
  int _selectedTabIndex = 0; // 0: Lịch tuần, 1: Danh sách mua sắm
  WeekPlan _currentWeek = dummyWeekPlan;
  bool _showRecipeAddForm = false;
  final ScrollController _recipeScrollController = ScrollController();
  final GlobalKey<State<ShoppingListSection>> _shoppingListKey = GlobalKey();

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
          if (_selectedTabIndex == 0)
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

  void _handleMealAdded(int dayIndex, MealType mealType, Meal meal) {
    final List<DayPlan> updatedDays = List.from(_currentWeek.days);
    final DayPlan targetDay = updatedDays[dayIndex];
    final Map<MealType, MealSlot> newSlots = Map.of(targetDay.slots);
    final MealSlot currentSlot =
        newSlots[mealType] ?? MealSlot(type: mealType, meals: const []);
    newSlots[mealType] = currentSlot.addMeal(meal);

    updatedDays[dayIndex] = targetDay.copyWith(slots: newSlots);

    setState(() {
      _currentWeek = _currentWeek.copyWith(days: updatedDays);
    });

    // Ghi lại Supabase nếu meal có recipeId.
    if (meal.recipeId != null) {
      _persistMealToBackend(dayIndex, mealType, meal);

      // Thêm missing ingredients vào shopping list
      _addMissingIngredientsToShoppingList(dayIndex, meal);
    }
  }

  Future<void> _persistMealToBackend(
    int dayIndex,
    MealType mealType,
    Meal meal,
  ) async {
    final dayPlan = _currentWeek.days[dayIndex];
    final now = DateTime.now();
    // Tạm thời giả định tuần hiện tại là tháng hiện tại.
    final plannedDate = DateTime(now.year, now.month, dayPlan.dayOfMonth);

    // Map MealType (UI) -> MealTypeEnum (DB)
    MealTypeEnum dbMealType;
    switch (mealType) {
      case MealType.breakfast:
        dbMealType = MealTypeEnum.breakfast;
        break;
      case MealType.lunch:
        dbMealType = MealTypeEnum.lunch;
        break;
      case MealType.dinner:
        dbMealType = MealTypeEnum.dinner;
        break;
    }

    try {
      final supabase = MealPlanService.instance;
      // Dùng user hiện tại (profiles.id == auth.user.id).
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      await supabase.addRecipeToSlot(
        profileId: userId,
        plannedDate: plannedDate,
        mealType: dbMealType,
        recipeId: meal.recipeId!,
      );
    } catch (_) {
      // TODO: có thể show snackbar báo lỗi nếu cần.
    }
  }

  /// Thêm missing ingredients vào shopping list khi add meal
  Future<void> _addMissingIngredientsToShoppingList(
    int dayIndex,
    Meal meal,
  ) async {
    if (meal.recipeId == null) return;

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final dayPlan = _currentWeek.days[dayIndex];
      final now = DateTime.now();
      // Tạm thời giả định tuần hiện tại là tháng hiện tại
      final plannedDate = DateTime(now.year, now.month, dayPlan.dayOfMonth);

      // Tính toán week start (Monday của tuần chứa plannedDate)
      final weekStart = plannedDate.subtract(
        Duration(days: plannedDate.weekday - 1),
      );

      await ShoppingListService.instance.addMissingIngredientsToShoppingList(
        profileId: userId,
        recipeId: meal.recipeId!,
        weekStart: weekStart,
      );

      // Hiển thị thông báo cho user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Đã kiểm tra và thêm nguyên liệu thiếu vào danh sách mua sắm',
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh shopping list nếu đang hiển thị tab shopping list
        if (_selectedTabIndex == 1) {
          _refreshShoppingListIfVisible();
        }
      }
    } catch (e) {
      // Hiển thị lỗi nếu có
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi thêm nguyên liệu: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _refreshShoppingListIfVisible() {
    final state = _shoppingListKey.currentState;
    if (state != null) {
      // Use dynamic to access refreshShoppingList method
      (state as dynamic).refreshShoppingList?.call();
    }
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
                onMealAdded: _handleMealAdded,
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
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ShoppingListSection(key: _shoppingListKey),
      ),
    );
  }
}
