enum MealType { breakfast, lunch, dinner }

extension MealTypeExt on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Sáng';
      case MealType.lunch:
        return 'Trưa';
      case MealType.dinner:
        return 'Tối';
    }
  }
}

class Meal {
  /// ID recipe trong bảng `recipes` (có thể null với dữ liệu dummy).
  final int? recipeId;
  final String name;
  final String imageUrl;

  const Meal({this.recipeId, required this.name, required this.imageUrl});
}

/// Một ô bữa ăn trong ngày.
///
/// Hỗ trợ chứa nhiều món (nhiều công thức) trong cùng một slot.
class MealSlot {
  final MealType type;
  final List<Meal> meals;

  const MealSlot({required this.type, this.meals = const []});

  bool get isEmpty => meals.isEmpty;

  MealSlot addMeal(Meal meal) {
    return MealSlot(type: type, meals: [...meals, meal]);
  }
}

class DayPlan {
  final String weekdayLabel; // Thứ 2, Thứ 3, ..., CN
  final int dayOfMonth; // 13, 14, ...
  final Map<MealType, MealSlot> slots;

  const DayPlan({
    required this.weekdayLabel,
    required this.dayOfMonth,
    required this.slots,
  });

  DayPlan copyWith({
    String? weekdayLabel,
    int? dayOfMonth,
    Map<MealType, MealSlot>? slots,
  }) {
    return DayPlan(
      weekdayLabel: weekdayLabel ?? this.weekdayLabel,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      slots: slots ?? this.slots,
    );
  }
}

class WeekPlan {
  final String label; // "Tuần 2 (13 - 19/11/2025)"
  final List<DayPlan> days;
  final int selectedDayIndex;

  const WeekPlan({
    required this.label,
    required this.days,
    this.selectedDayIndex = 0,
  });

  WeekPlan copyWith({
    String? label,
    List<DayPlan>? days,
    int? selectedDayIndex,
  }) {
    return WeekPlan(
      label: label ?? this.label,
      days: days ?? this.days,
      selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
    );
  }
}

/// Dummy data cho tuần hiện tại (Tuần 2: 13 - 19/11/2025)
final WeekPlan dummyWeekPlan = WeekPlan(
  label: 'Tuần 2 (15 - 21/12/2025)',
  selectedDayIndex: 2, // index 2 -> Thứ 4 (15) được highlight
  days: [
    DayPlan(
      weekdayLabel: 'Thứ 2',
      dayOfMonth: 15,
      slots: {
        MealType.breakfast: MealSlot(
          type: MealType.breakfast,
          meals: [
            Meal(
              name: 'Phở bò',
              imageUrl:
                  'https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg',
            ),
          ],
        ),
        MealType.lunch: MealSlot(type: MealType.lunch),
        MealType.dinner: MealSlot(type: MealType.dinner),
      },
    ),
    DayPlan(
      weekdayLabel: 'Thứ 3',
      dayOfMonth: 16,
      slots: {
        MealType.breakfast: MealSlot(type: MealType.breakfast),
        MealType.lunch: MealSlot(
          type: MealType.lunch,
          meals: [
            Meal(
              name: 'Mì Ý sốt thịt',
              imageUrl:
                  'https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg',
            ),
          ],
        ),
        MealType.dinner: MealSlot(type: MealType.dinner),
      },
    ),
    DayPlan(
      weekdayLabel: 'Thứ 4',
      dayOfMonth: 17,
      slots: {
        MealType.breakfast: MealSlot(
          type: MealType.breakfast,
          meals: [
            Meal(
              name: 'Phở Bò Hà Nội',
              imageUrl:
                  'https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg',
            ),
          ],
        ),
        MealType.lunch: MealSlot(
          type: MealType.lunch,
          meals: [
            Meal(
              name: 'Gà nướng mật ong',
              imageUrl:
                  'https://images.pexels.com/photos/1633578/pexels-photo-1633578.jpeg',
            ),
          ],
        ),
        MealType.dinner: MealSlot(
          type: MealType.dinner,
          meals: [
            Meal(
              name: 'Vịt tiềm',
              imageUrl:
                  'https://images.pexels.com/photos/1640772/pexels-photo-1640772.jpeg',
            ),
          ],
        ),
      },
    ),
    DayPlan(
      weekdayLabel: 'Thứ 5',
      dayOfMonth: 18,
      slots: {
        MealType.breakfast: MealSlot(type: MealType.breakfast),
        MealType.lunch: MealSlot(type: MealType.lunch),
        MealType.dinner: MealSlot(type: MealType.dinner),
      },
    ),
    DayPlan(
      weekdayLabel: 'Thứ 6',
      dayOfMonth: 19,
      slots: {
        MealType.breakfast: MealSlot(type: MealType.breakfast),
        MealType.lunch: MealSlot(type: MealType.lunch),
        MealType.dinner: MealSlot(type: MealType.dinner),
      },
    ),
    DayPlan(
      weekdayLabel: 'Thứ 7',
      dayOfMonth: 20,
      slots: {
        MealType.breakfast: MealSlot(type: MealType.breakfast),
        MealType.lunch: MealSlot(type: MealType.lunch),
        MealType.dinner: MealSlot(type: MealType.dinner),
      },
    ),
    DayPlan(
      weekdayLabel: 'CN',
      dayOfMonth: 21,
      slots: {
        MealType.breakfast: MealSlot(type: MealType.breakfast),
        MealType.lunch: MealSlot(type: MealType.lunch),
        MealType.dinner: MealSlot(type: MealType.dinner),
      },
    ),
  ],
);
