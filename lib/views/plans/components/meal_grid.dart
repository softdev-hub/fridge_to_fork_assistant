import 'package:flutter/material.dart';
import 'meal_card.dart';
import 'plan_models.dart';

class MealGrid extends StatelessWidget {
  final WeekPlan weekPlan;
  final Function(DayPlan, DateTime)? onDaySelected;

  const MealGrid({Key? key, required this.weekPlan, this.onDaySelected})
    : super(key: key);

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
          child: GestureDetector(
            onTap: () {
              if (onDaySelected != null) {
                // Calculate the actual date based on the day of month
                final now = DateTime.now();
                final selectedDate = DateTime(
                  now.year,
                  now.month,
                  day.dayOfMonth,
                );
                onDaySelected!(day, selectedDate);
              }
            },
            child: Column(
              children: [
                Center(
                  child: Text(
                    day.weekdayLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    day.dayOfMonth.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? primary : defaultText,
                    ),
                  ),
                ),
              ],
            ),
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
