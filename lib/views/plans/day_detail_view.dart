import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/enums.dart';
import '../../services/meal_plan_service.dart';
import '../../services/shopping_list_service.dart';
import 'components/plan_models.dart';
import 'components/day_detail_meal_card.dart';
import 'components/missing_ingredients.dart';
import '../recipes/components/recipe_card_list.dart';
import '../recipes/recipe_detail_view.dart';

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
  late DayPlan _localDayPlan;
  bool _hasChanges = false; // Flag để track thay đổi
  bool _isDeleting = false;
  final List<Map<String, dynamic>> _deletedEvents = [];

  @override
  void initState() {
    super.initState();
    // Tạo local copy để có thể cập nhật UI
    _localDayPlan = widget.dayPlan;
  }

  @override
  void didUpdateWidget(DayDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Khi widget được update (user quay lại), reload dayPlan mới từ parent
    if (oldWidget.dayPlan != widget.dayPlan) {
      print('🔄 DayDetailView received updated dayPlan, reloading...');
      setState(() {
        _localDayPlan = widget.dayPlan;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        try {
          if (_isDeleting) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đang xoá, vui lòng đợi...'),
                  backgroundColor: Color(0xFF9CA3AF),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            }
            return false;
          }
          print('🔙 WillPop triggered with changes: $_hasChanges');
          Navigator.of(
            context,
          ).pop({'changed': _hasChanges, 'removed': _deletedEvents});
          return false; // Prevent default pop behavior
        } catch (e, stackTrace) {
          print('❌ Error during navigation pop: $e');
          print('Stack trace: $stackTrace');
          // Fallback: just pop normally
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              try {
                if (_isDeleting) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đang xoá, vui lòng đợi...'),
                      backgroundColor: Color(0xFF9CA3AF),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                print('🔙 Back button pressed with changes: $_hasChanges');
                Navigator.of(
                  context,
                ).pop({'changed': _hasChanges, 'removed': _deletedEvents});
              } catch (e, stackTrace) {
                print('❌ Error during back navigation: $e');
                print('Stack trace: $stackTrace');
                // Fallback: simple pop
                Navigator.of(context).pop();
              }
            },
          ),
          titleSpacing: 0,
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
        body: Container(
          color: const Color(0xFFF8F9FA),
          child: SafeArea(
            child: Column(children: [Expanded(child: _buildDayPlanContent())]),
          ),
        ),
      ),
    );
  }

  Widget _buildDayPlanContent() {
    return SingleChildScrollView(
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
    final mealSlot = _localDayPlan.slots[mealType]!;

    if (mealSlot.meals.isEmpty) {
      // Show empty card when no meals
      return DayDetailMealCard(mealType: mealType, meal: null, onTap: null);
    }

    // Show all meals in this slot
    return Column(
      children: List.generate(mealSlot.meals.length, (index) {
        final meal = mealSlot.meals[index];
        final bool goToDetail = mealType == MealType.breakfast;

        final card = DayDetailMealCard(
          mealType: index == 0
              ? mealType
              : null, // Only show meal type label for first card
          meal: meal,
          onTap: goToDetail ? () => _openRecipeDetail(meal) : null,
          onDelete: () => _removeMealFromPlan(mealType, meal, index),
        );

        return Column(
          children: [
            if (index > 0)
              const SizedBox(height: 8), // Space between multiple meals
            goToDetail
                ? GestureDetector(
                    onTap: () => _openRecipeDetail(meal),
                    child: card,
                  )
                : card,
          ],
        );
      }),
    );
  }

  void _openRecipeDetail(Meal meal) {
    final recipe = RecipeCardModel(
      name: meal.name,
      timeLabel: '25 phút',
      difficulty: RecipeDifficulty.medium,
      mealTime: RecipeMealTime.breakfast,
      matchType: MatchType.full,
      availableIngredients: 5,
      totalIngredients: 8,
      missingCount: 3,
      expiringCount: null,
      isExpiring: false,
      imageUrl: meal.imageUrl,
    );

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => RecipeDetailView(recipe: recipe)));
  }

  /// Xoá món khỏi kế hoạch và shopping list
  Future<void> _removeMealFromPlan(
    MealType mealType,
    Meal meal,
    int index,
  ) async {
    if (meal.recipeId == null) return;
    if (_isDeleting) return;

    setState(() {
      _isDeleting = true;
    });

    print(
      '🗑️ Starting removal process for: ${meal.name} (Recipe ID: ${meal.recipeId}, Index: $index)',
    );

    // Store meal details for specific removal tracking
    final mealToRemove = {
      'name': meal.name,
      'imageUrl': meal.imageUrl,
      'recipeId': meal.recipeId,
      'mealPlanId': meal.mealPlanId,
      'index': index,
    };

    // 1. Hiển thị loading state trước khi thực hiện database operations
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đang xoá "${meal.name}"...'),
          backgroundColor: const Color(0xFF9CA3AF),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      // Map MealType to MealTypeEnum
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

      print(
        '🗑️ DATABASE FIRST - Removing meal: ${meal.name} (Recipe ID: ${meal.recipeId}, MealPlan ID: ${meal.mealPlanId})',
      );

      // 2. Ưu tiên dùng mealPlanId gắn trên meal để xoá chính xác
      int? mealPlanId = meal.mealPlanId;

      // Nếu thiếu mealPlanId (dữ liệu không từ DB), fallback tìm theo join
      if (mealPlanId == null) {
        final mealPlansWithRecipe = await Supabase.instance.client
            .from('meal_plans')
            .select('meal_plan_id, meal_plan_recipes!inner(recipe_id)')
            .eq('profile_id', userId)
            .eq(
              'planned_date',
              widget.selectedDate.toIso8601String().split('T')[0],
            )
            .eq('meal_type', dbMealType.toDbValue())
            .eq('meal_plan_recipes.recipe_id', meal.recipeId!);

        print(
          '🔍 Found ${mealPlansWithRecipe.length} meal plans containing recipe ${meal.recipeId}',
        );
        if (mealPlansWithRecipe.isNotEmpty) {
          mealPlanId = mealPlansWithRecipe[0]['meal_plan_id'] as int;
          print('🎯 Using meal plan ID from join: $mealPlanId for deletion');
        }
      }

      if (mealPlanId != null) {
        print('🎯 Deleting from meal_plan_id: $mealPlanId');

        // 3. Xoá recipe khỏi meal_plan_recipes (DATABASE OPERATION)
        await MealPlanService.instance.removeRecipeFromSlot(
          mealPlanId: mealPlanId,
          recipeId: meal.recipeId!,
        );

        print('✅ Removed from meal_plan_recipes');

        // 4. Xoá missing ingredients khỏi shopping list (DATABASE OPERATION)
        await _removeIngredientsFromShoppingList(
          recipeId: meal.recipeId!,
          mealPlanId: mealPlanId,
        );

        print('✅ Removed ingredients from shopping list');
      } else {
        print('⚠️ Meal plan ID not found (meal already deleted from database)');
        // Vẫn xoá ingredients khỏi shopping list nếu có
        await _removeIngredientsFromShoppingList(recipeId: meal.recipeId!);
      }

      // 5. DATABASE OPERATIONS THÀNH CÔNG - BÂY GIỜ MỚI CẬP NHẬT UI
      setState(() {
        final currentSlot = _localDayPlan.slots[mealType]!;
        final updatedMeals = List<Meal>.from(currentSlot.meals);
        if (index >= 0 && index < updatedMeals.length) {
          updatedMeals.removeAt(index);
        }
        final updatedSlots = Map<MealType, MealSlot>.from(_localDayPlan.slots);
        updatedSlots[mealType] = currentSlot.copyWith(meals: updatedMeals);
        _localDayPlan = _localDayPlan.copyWith(slots: updatedSlots);
      });

      print('✅ UI updated AFTER successful database operations');

      // 6. Ghi nhận event xóa với thông tin chi tiết để PlanView cập nhật UI chính xác
      _deletedEvents.add({
        'date': widget.selectedDate.toIso8601String().split('T')[0],
        'mealType': mealType.name,
        'recipeId': meal.recipeId,
        'mealPlanId':
            mealPlanId, // Có thể null nhưng vẫn cần để PlanView biết xoá
        'mealDetails': mealToRemove, // Thông tin chi tiết để xóa chính xác
      });

      _hasChanges = true;
      print('✅ Database and UI operations completed successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xoá "${meal.name}" thành công'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ Error removing meal from DATABASE: $e');
      print('Stack trace: $stackTrace');

      // DATABASE ERROR - Không cập nhật UI và không thêm vào _deletedEvents
      // vì database operation thất bại, meal vẫn còn trong database

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lỗi xoá "${meal.name}" khỏi cơ sở dữ liệu: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Thử lại',
              textColor: Colors.white,
              onPressed: () => _removeMealFromPlan(mealType, meal, index),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  /// Xoá missing ingredients khỏi shopping list
  Future<void> _removeIngredientsFromShoppingList({
    required int recipeId,
    int? mealPlanId,
  }) async {
    try {
      print(
        '🛒 Removing ingredients for recipe $recipeId from shopping list (mealPlanId: $mealPlanId)',
      );

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      // Lấy weekly shopping list
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      if (mealPlanId != null) {
        await ShoppingListService.instance.removeAutoItemsForMeal(
          profileId: userId,
          weekStart: weekStart,
          mealPlanId: mealPlanId,
          recipeId: recipeId,
        );
      } else {
        // Fallback (legacy): không có mealPlanId thì chỉ cleanup auto-items theo recipe.
        // Manual items không có source_recipe_id nên không bị ảnh hưởng.
        final weeklyList = await ShoppingListService.instance
            .getOrCreateWeeklyList(profileId: userId, weekStart: weekStart);
        await Supabase.instance.client
            .from('shopping_list_items')
            .delete()
            .eq('list_id', weeklyList.listId!)
            .eq('source_recipe_id', recipeId)
            .like('source_name', '%Từ công thức%');
      }

      print(
        '✅ Đã xoá missing ingredients cho recipe $recipeId khỏi shopping list',
      );

      // Kiểm tra xem còn meal plans nào khác không, nếu không thì cleanup hoàn toàn
      // NOTE: Không cleanup manual items ở đây.

      print('✅ Completed shopping list cleanup process');
    } catch (e) {
      print('❌ Error removing ingredients from shopping list: $e');
    }
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
