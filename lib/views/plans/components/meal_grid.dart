import 'package:flutter/material.dart';
import 'meal_card.dart';
import 'plan_models.dart';

class MealGrid extends StatelessWidget {
  final WeekPlan weekPlan;

  const MealGrid({Key? key, required this.weekPlan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDayHeaderRow(),
        const SizedBox(height: 8),
        _buildMealRow(MealType.breakfast),
        const SizedBox(height: 8),
        _buildMealRow(MealType.lunch),
        const SizedBox(height: 8),
        _buildMealRow(MealType.dinner),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildDayHeaderRow() {
    return Row(
      children: List.generate(weekPlan.days.length, (index) {
        final day = weekPlan.days[index];
        final bool isSelected = index == weekPlan.selectedDayIndex;

        final Color primary = const Color(0xFF22C55E);
        final Color defaultText = const Color(0xFF0F172A);

        return Expanded(
          child: Column(
            children: [
              Text(
                day.weekdayLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? primary : const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                day.dayOfMonth.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? primary : defaultText,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMealRow(MealType mealType) {
    return SizedBox(
      height: 110,
      child: Row(
        children: List.generate(weekPlan.days.length, (dayIndex) {
          final day = weekPlan.days[dayIndex];
          final mealSlot = day.slots[mealType]!;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    dayIndex == 0 || dayIndex == weekPlan.days.length - 1
                    ? 0
                    : 2,
              ),
              child: MealCard(
                mealType: mealType,
                meal: mealSlot.meal,
                onTap: () {
                  // TODO: open recipe detail or add meal
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}
