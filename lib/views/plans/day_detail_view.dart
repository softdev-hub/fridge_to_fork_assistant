import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
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
    final mealSlot = widget.dayPlan.slots[mealType]!;

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
    final recipe = Recipe(
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
    );

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => RecipeDetailView(recipe: recipe)));
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
