import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/enums.dart';
import '../../models/meal_plan.dart';
import '../../services/meal_plan_service.dart';
import '../../services/shopping_list_service.dart';
import '../../services/shared_recipe_service.dart';
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
  State<PlanView> createState() => PlanViewState();
}

class PlanViewState extends State<PlanView> {
  int _selectedTabIndex = 0; // 0: Lịch tuần, 1: Danh sách mua sắm
  WeekPlan _currentWeek = dummyWeekPlan;
  bool _showRecipeAddForm = false;
  final ScrollController _recipeScrollController = ScrollController();
  final GlobalKey _shoppingListKey = GlobalKey();

  DateTime? _selectedWeekStart;

  DateTime _weekStartDateOnly(DateTime dateTime) {
    final d = DateUtils.dateOnly(dateTime);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  DateTime _getSelectedWeekStart() {
    return _selectedWeekStart ??= _weekStartDateOnly(DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    _selectedWeekStart = _weekStartDateOnly(DateTime.now());
    _loadWeekPlan();
    _checkSelectedRecipe();
  }

  Future<void> _shiftWeekBy(int days) async {
    final currentWeekStart = _getSelectedWeekStart();
    final newWeekStart = currentWeekStart.add(Duration(days: days));
    if (newWeekStart == currentWeekStart) return;
    setState(() {
      _selectedWeekStart = newWeekStart;
      _showRecipeAddForm = false;
    });
    await _loadWeekPlan();
    _refreshShoppingListIfVisible();
  }

  Future<void> _selectWeekByDate(DateTime selectedDate) async {
    final newWeekStart = _weekStartDateOnly(selectedDate);
    final currentWeekStart = _getSelectedWeekStart();
    if (newWeekStart == currentWeekStart) return;

    setState(() {
      _selectedWeekStart = newWeekStart;
      _showRecipeAddForm = false;
    });
    await _loadWeekPlan();
    _refreshShoppingListIfVisible();
  }

  /// Load meal plans từ database cho tuần hiện tại
  Future<void> _loadWeekPlan() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final weekStart = _getSelectedWeekStart();
      final weekEnd = weekStart.add(const Duration(days: 6));

      print('🔍 Loading meal plans for week: $weekStart to $weekEnd');

      // Lấy meal plans từ database
      final mealPlans = await MealPlanService.instance.getMealPlansForWeek(
        profileId: userId,
        weekStart: weekStart,
        weekEnd: weekEnd,
      );

      print('📋 Found ${mealPlans.length} meal plans');

      // Convert meal plans thành UI format và update _currentWeek
      final updatedWeek = await _buildWeekPlanFromDatabase(
        mealPlans,
        weekStart,
      );
      if (mounted) {
        setState(() {
          _currentWeek = updatedWeek;
        });
        print('✅ UI updated with ${updatedWeek.days.length} days');
      }
    } catch (e) {
      print('❌ Error loading meal plans: $e');
    }
  }

  /// Convert meal plans từ database thành WeekPlan UI format
  Future<WeekPlan> _buildWeekPlanFromDatabase(
    List<MealPlan> mealPlans,
    DateTime weekStart,
  ) async {
    print('🏗️ Building week plan from ${mealPlans.length} meal plans');

    try {
      // Group meal plans theo ngày
      final Map<int, List<MealPlan>> plansByDay = {};
      for (final plan in mealPlans) {
        final dayIndex = DateUtils.dateOnly(
          plan.plannedDate,
        ).difference(weekStart).inDays;
        if (dayIndex >= 0 && dayIndex < 7) {
          plansByDay[dayIndex] ??= [];
          plansByDay[dayIndex]!.add(plan);
        }
      }

      // Lấy thông tin về các recipes trong meal plans
      final Set<int> allRecipeIds = {};
      for (final plan in mealPlans) {
        // Get recipes for this meal plan
        try {
          final response = await Supabase.instance.client
              .from('meal_plan_recipes')
              .select('recipe_id')
              .eq('meal_plan_id', plan.mealPlanId!);

          final recipeIds = (response as List)
              .map((json) => json['recipe_id'] as int?)
              .where((id) => id != null)
              .cast<int>();

          allRecipeIds.addAll(recipeIds);
        } catch (e) {
          print('❌ Error loading recipes for meal plan ${plan.mealPlanId}: $e');
        }
      }

      // Lấy thông tin chi tiết về recipes
      final Map<int, Meal> recipeMeals = {};
      if (allRecipeIds.isNotEmpty) {
        try {
          print(
            '🔍 Loading details for ${allRecipeIds.length} recipes: $allRecipeIds',
          );

          final recipesResponse = await Supabase.instance.client
              .from('recipes')
              .select('recipe_id, title, image_url')
              .inFilter('recipe_id', allRecipeIds.toList());

          print(
            '✅ Loaded ${recipesResponse.length} recipe details from database',
          );

          for (final recipeJson in recipesResponse) {
            final recipeId = recipeJson['recipe_id'] as int;
            recipeMeals[recipeId] = Meal(
              recipeId: recipeId,
              name: recipeJson['title'] as String,
              imageUrl:
                  recipeJson['image_url'] as String? ??
                  'https://images.unsplash.com/photo-1548943487-a2e4e43b4858?w=400',
            );
          }

          print('📋 Recipe meals map: ${recipeMeals.keys.toList()}');
        } catch (e) {
          print('❌ Error loading recipe details: $e');
        }
      }

      // Build DayPlan list (single loop with correct logic)
      final List<DayPlan> days = [];
      final weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

      for (int i = 0; i < 7; i++) {
        final dayDate = weekStart.add(Duration(days: i));
        final dayPlans = plansByDay[i] ?? [];

        print('📅 Day $i (${weekdays[i]}): ${dayPlans.length} meal plans');

        // Build meal slots for this day
        final Map<MealType, MealSlot> slots = {};
        for (final mealType in MealType.values) {
          final dbMealType = _mapUIToDbMealType(mealType);
          final mealsForSlot = <Meal>[];

          for (final plan in dayPlans) {
            if (plan.mealType == dbMealType) {
              // Get recipes for this meal plan
              try {
                final response = await Supabase.instance.client
                    .from('meal_plan_recipes')
                    .select('recipe_id')
                    .eq('meal_plan_id', plan.mealPlanId!);

                final recipeIds = (response as List)
                    .map((json) => json['recipe_id'] as int?)
                    .where((id) => id != null)
                    .cast<int>();

                print(
                  '🍽️ Meal plan ${plan.mealPlanId} (${mealType.name}): ${recipeIds.length} recipes',
                );

                for (final recipeId in recipeIds) {
                  if (recipeMeals.containsKey(recipeId)) {
                    final baseMeal = recipeMeals[recipeId]!;
                    // Attach mealPlanId so DayDetail can target the exact plan when deleting
                    mealsForSlot.add(
                      Meal(
                        recipeId: baseMeal.recipeId,
                        name: baseMeal.name,
                        imageUrl: baseMeal.imageUrl,
                        mealPlanId: plan.mealPlanId!,
                      ),
                    );
                    print(
                      '✅ Added recipe $recipeId: ${baseMeal.name} (meal_plan_id: ${plan.mealPlanId})',
                    );
                  } else {
                    print('❌ Recipe $recipeId not found in recipeMeals cache');
                  }
                }
              } catch (e) {
                print('❌ Error loading meal plan recipes: $e');
              }
            }
          }

          print('🍽️ Final meals for ${mealType.name}: ${mealsForSlot.length}');
          slots[mealType] = MealSlot(type: mealType, meals: mealsForSlot);
        }

        days.add(
          DayPlan(
            weekdayLabel: weekdays[i],
            dayOfMonth: dayDate.day,
            slots: slots,
          ),
        );
      }

      final weekLabel = _buildWeekLabel(weekStart);
      final todayWeekStart = _weekStartDateOnly(DateTime.now());
      return WeekPlan(
        label: weekLabel,
        days: days,
        selectedDayIndex: weekStart == todayWeekStart
            ? DateTime.now().weekday - 1
            : 0,
      );
    } catch (e) {
      print('❌ Error building week plan from database: $e');
      return dummyWeekPlan;
    }
  }

  /// Map UI MealType to database MealTypeEnum
  MealTypeEnum _mapUIToDbMealType(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return MealTypeEnum.breakfast;
      case MealType.lunch:
        return MealTypeEnum.lunch;
      case MealType.dinner:
        return MealTypeEnum.dinner;
    }
  }

  /// Build week label string
  String _buildWeekLabel(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return 'Tuần ${_getWeekOfYear(weekStart)} (${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month}/${weekEnd.year})';
  }

  /// Get week number of year
  int _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysFromFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysFromFirstDay / 7).ceil() + 1;
  }

  void _checkSelectedRecipe() {
    final selectedRecipe = SharedRecipeService().selectedRecipe;
    if (selectedRecipe != null && SharedRecipeService().isRecipeFromTab) {
      print('🎯 Tìm thấy selected recipe: ${selectedRecipe.name}');
      print('🎯 Missing names: ${selectedRecipe.missingNames}');

      // Hiển thị bottom sheet với recipe được chọn
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _showRecipeAddForm = true;
        });

        // Hiển thị thông báo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã chọn "${selectedRecipe.name}" từ công thức. Kéo vào lịch để thêm vào kế hoạch.',
            ),
            duration: const Duration(seconds: 4),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    } else {
      print('❌ Không có selected recipe hoặc không từ tab');
    }
  }

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
                      initialDate: _getSelectedWeekStart(),
                      onDateSelected: (selectedDate) async {
                        Navigator.of(context).pop();
                        await _selectWeekByDate(selectedDate);
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
    print(
      '🔍 _handleMealAdded: Recipe ID ${meal.recipeId}, Name: ${meal.name}',
    );

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
    }

    // Clear selected recipe sau khi đã thêm vào kế hoạch
    SharedRecipeService().clearSelectedRecipe();

    // Ẩn bottom sheet
    setState(() {
      _showRecipeAddForm = false;
    });

    // Hiển thị thông báo thành công
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm "${meal.name}" vào kế hoạch'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _persistMealToBackend(
    int dayIndex,
    MealType mealType,
    Meal meal,
  ) async {
    // Tính planned_date dựa trên tuần hiện tại (date-only)
    final weekStart = _getSelectedWeekStart();
    final plannedDate = weekStart.add(Duration(days: dayIndex));

    print('🗓️ Planning for: $plannedDate (dayIndex: $dayIndex)');

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

      final result = await supabase.addRecipeToSlot(
        profileId: userId,
        plannedDate: plannedDate,
        mealType: dbMealType,
        recipeId: meal.recipeId!,
      );

      print('✅ Meal plan created: ${result.toJson()}');

      // Attach mealPlanId vào local state để DayDetail xoá đúng record.
      _attachMealPlanIdToLocalMeal(
        dayIndex: dayIndex,
        mealType: mealType,
        recipeId: meal.recipeId!,
        mealPlanId: result.mealPlanId,
      );

      // Add missing ingredients theo meal_plan_id để có thể trừ chính xác khi xoá.
      await ShoppingListService.instance.addMissingIngredientsToShoppingList(
        profileId: userId,
        recipeId: meal.recipeId!,
        weekStart: weekStart,
        mealPlanId: result.mealPlanId,
      );

      _refreshShoppingListIfVisible();
    } catch (e) {
      print('❌ Error creating meal plan: $e');
      // TODO: có thể show snackbar báo lỗi nếu cần.
    }
  }

  void _attachMealPlanIdToLocalMeal({
    required int dayIndex,
    required MealType mealType,
    required int recipeId,
    required int mealPlanId,
  }) {
    try {
      final updatedDays = List<DayPlan>.from(_currentWeek.days);
      if (dayIndex < 0 || dayIndex >= updatedDays.length) return;

      final day = updatedDays[dayIndex];
      final slots = Map<MealType, MealSlot>.from(day.slots);
      final slot = slots[mealType] ?? MealSlot(type: mealType, meals: const []);

      final meals = List<Meal>.from(slot.meals);
      final index = meals.lastIndexWhere((m) => m.recipeId == recipeId);
      if (index < 0) return;

      final current = meals[index];
      if (current.mealPlanId == mealPlanId) return;

      meals[index] = Meal(
        recipeId: current.recipeId,
        name: current.name,
        imageUrl: current.imageUrl,
        mealPlanId: mealPlanId,
      );

      slots[mealType] = slot.copyWith(meals: meals);
      updatedDays[dayIndex] = day.copyWith(slots: slots);

      if (!mounted) return;
      setState(() {
        _currentWeek = _currentWeek.copyWith(days: updatedDays);
      });
    } catch (e) {
      // Non-fatal
      print('⚠️ Failed to attach mealPlanId locally: $e');
    }
  }

  void _refreshShoppingListIfVisible() {
    final state = _shoppingListKey.currentState;
    if (state != null) {
      // Use dynamic to access refreshShoppingList method
      (state as dynamic).refreshShoppingList?.call();
    }
  }

  /// Public method để force refresh toàn bộ plan view
  Future<void> forceRefresh() async {
    print('🔄 Force refreshing entire PlanView');
    await _loadWeekPlan();
    _refreshShoppingListIfVisible();
    if (mounted) {
      setState(() {});
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
              _shiftWeekBy(-7);
            },
            onNext: () {
              _shiftWeekBy(7);
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
                onDaySelected: (dayPlan, selectedDate) async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DayDetailView(
                        dayPlan: dayPlan,
                        selectedDate: selectedDate,
                      ),
                    ),
                  );

                  // Nếu có thay đổi từ DayDetailView, cập nhật nhanh UI và reload meal plan
                  print('📝 DayDetailView returned: $result');

                  bool changed = false;
                  List<dynamic> removed = const [];
                  if (result is bool) {
                    changed = result;
                  } else if (result is Map) {
                    changed = result['changed'] == true;
                    removed = (result['removed'] as List?) ?? const [];
                  }

                  // Áp dụng xoá nhanh vào _currentWeek trước khi gọi backend
                  if (changed && removed.isNotEmpty) {
                    try {
                      final weekStart = _getSelectedWeekStart();
                      final updatedDays = List<DayPlan>.from(_currentWeek.days);

                      for (final item in removed) {
                        final dateStr = item['date'] as String;
                        final recipeId = item['recipeId'] as int?;
                        final mealTypeStr = item['mealType'] as String?;
                        final mealDetails = item['mealDetails'] as Map?;
                        if (recipeId == null || mealTypeStr == null) continue;

                        final date = DateUtils.dateOnly(
                          DateTime.parse(dateStr),
                        );
                        final dIndex = date.difference(weekStart).inDays;
                        if (dIndex < 0 || dIndex >= 7) continue;

                        final mt = mealTypeStr == 'breakfast'
                            ? MealType.breakfast
                            : mealTypeStr == 'lunch'
                            ? MealType.lunch
                            : MealType.dinner;

                        final day = updatedDays[dIndex];
                        final slots = Map<MealType, MealSlot>.from(day.slots);
                        final slot =
                            slots[mt] ?? MealSlot(type: mt, meals: const []);

                        // Use specific meal details for precise removal
                        List<Meal> newMeals = List<Meal>.from(slot.meals);
                        bool removed = false;

                        if (mealDetails != null &&
                            mealDetails['index'] is int) {
                          // Remove by specific index if available
                          final removeIndex = mealDetails['index'] as int;
                          if (removeIndex >= 0 &&
                              removeIndex < newMeals.length) {
                            final mealAtIndex = newMeals[removeIndex];
                            if (mealAtIndex.recipeId == recipeId &&
                                mealAtIndex.name == mealDetails['name']) {
                              newMeals.removeAt(removeIndex);
                              removed = true;
                              print(
                                '✅ Removed meal at index $removeIndex: ${mealDetails['name']}',
                              );
                            }
                          }
                        }

                        if (!removed) {
                          // Fallback: remove first matching meal by recipeId
                          final indexToRemove = newMeals.indexWhere(
                            (m) => m.recipeId == recipeId,
                          );
                          if (indexToRemove >= 0) {
                            final removedMeal = newMeals.removeAt(
                              indexToRemove,
                            );
                            print(
                              '✅ Removed meal (fallback) at index $indexToRemove: ${removedMeal.name}',
                            );
                          } else {
                            print(
                              '⚠️ No matching meal found to remove for recipe ID: $recipeId',
                            );
                            // Fallback: local mapping mismatch; reload from DB.
                            _loadWeekPlan();
                          }
                        }

                        slots[mt] = slot.copyWith(meals: newMeals);
                        updatedDays[dIndex] = day.copyWith(slots: slots);
                      }

                      if (mounted) {
                        setState(() {
                          _currentWeek = _currentWeek.copyWith(
                            days: updatedDays,
                          );
                        });
                        print('✅ Local state updated after meal deletion');
                      }
                    } catch (e, stackTrace) {
                      print('⚠️ Quick update after deletion failed: $e');
                      print('Stack trace: $stackTrace');
                      // Fallback: reload từ database nếu local update thất bại
                      if (mounted) {
                        _loadWeekPlan();
                      }
                    }
                  }

                  if (changed) {
                    print(
                      '🔄 Changes detected, updating shopping list only...',
                    );

                    try {
                      // CHỈ refresh shopping list, KHÔNG reload meal plan từ database
                      // vì chúng ta đã cập nhật local state (_currentWeek) ở trên rồi
                      final shoppingListState = _shoppingListKey.currentState;
                      if (shoppingListState != null) {
                        (shoppingListState as dynamic).refreshShoppingList
                            ?.call();
                      }
                      print(
                        '✅ Shopping list refreshed, meal plan UI preserved',
                      );

                      // Keep week UI consistent with DB even if local quick-removal missed.
                      _loadWeekPlan();
                    } catch (e) {
                      print('⚠️ Error refreshing shopping list: $e');
                      // Fallback: reload toàn bộ nếu refresh lỗi
                      _loadWeekPlan();
                    }
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShoppingListPlaceholder() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ShoppingListSection(key: _shoppingListKey),
    );
  }
}
