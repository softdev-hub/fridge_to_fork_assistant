/// Enum for unit types matching database unit_enum
enum UnitEnum {
  g,
  ml,
  cai, // 'cái' in database
  qua; // 'quả' in database

  String get displayName {
    switch (this) {
      case UnitEnum.g:
        return 'g';
      case UnitEnum.ml:
        return 'ml';
      case UnitEnum.cai:
        return 'cái';
      case UnitEnum.qua:
        return 'quả';
    }
  }

  String toDbValue() {
    switch (this) {
      case UnitEnum.g:
        return 'g';
      case UnitEnum.ml:
        return 'ml';
      case UnitEnum.cai:
        return 'cái';
      case UnitEnum.qua:
        return 'quả';
    }
  }

  static UnitEnum fromDbValue(String value) {
    switch (value) {
      case 'g':
        return UnitEnum.g;
      case 'ml':
        return UnitEnum.ml;
      case 'cái':
        return UnitEnum.cai;
      case 'quả':
        return UnitEnum.qua;
      default:
        throw ArgumentError('Unknown unit value: $value');
    }
  }
}

/// Enum for meal types matching database meal_type_enum
enum MealTypeEnum {
  breakfast,
  lunch,
  dinner;

  String get displayName {
    switch (this) {
      case MealTypeEnum.breakfast:
        return 'Bữa sáng';
      case MealTypeEnum.lunch:
        return 'Bữa trưa';
      case MealTypeEnum.dinner:
        return 'Bữa tối';
    }
  }

  String toDbValue() => name;

  static MealTypeEnum fromDbValue(String value) {
    return MealTypeEnum.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Unknown meal type value: $value'),
    );
  }
}

/// Enum for meal plan status matching database meal_plan_status_enum
enum MealPlanStatusEnum {
  planned,
  done,
  skipped;

  String get displayName {
    switch (this) {
      case MealPlanStatusEnum.planned:
        return 'Đã lên kế hoạch';
      case MealPlanStatusEnum.done:
        return 'Đã hoàn thành';
      case MealPlanStatusEnum.skipped:
        return 'Đã bỏ qua';
    }
  }

  String toDbValue() => name;

  static MealPlanStatusEnum fromDbValue(String value) {
    return MealPlanStatusEnum.values.firstWhere(
      (e) => e.name == value,
      orElse: () =>
          throw ArgumentError('Unknown meal plan status value: $value'),
    );
  }
}

/// Enum for recipe difficulty matching database recipe_difficulty_enum
enum RecipeDifficultyEnum {
  easy,
  medium,
  hard;

  String get displayName {
    switch (this) {
      case RecipeDifficultyEnum.easy:
        return 'Dễ';
      case RecipeDifficultyEnum.medium:
        return 'Trung bình';
      case RecipeDifficultyEnum.hard:
        return 'Khó';
    }
  }

  String toDbValue() => name;

  static RecipeDifficultyEnum fromDbValue(String value) {
    return RecipeDifficultyEnum.values.firstWhere(
      (e) => e.name == value,
      orElse: () =>
          throw ArgumentError('Unknown recipe difficulty value: $value'),
    );
  }
}

/// Enum for ingredient category matching database ingredient_category_enum
enum IngredientCategoryEnum {
  sua, // 'sữa' in database
  thit, // 'thịt' in database
  rau, // 'rau' in database
  hat, // 'hạt' in database
  khac; // 'khác' in database

  String get displayName {
    switch (this) {
      case IngredientCategoryEnum.sua:
        return 'Sữa';
      case IngredientCategoryEnum.thit:
        return 'Thịt';
      case IngredientCategoryEnum.rau:
        return 'Rau';
      case IngredientCategoryEnum.hat:
        return 'Hạt';
      case IngredientCategoryEnum.khac:
        return 'Khác';
    }
  }

  String toDbValue() {
    switch (this) {
      case IngredientCategoryEnum.sua:
        return 'sữa';
      case IngredientCategoryEnum.thit:
        return 'thịt';
      case IngredientCategoryEnum.rau:
        return 'rau';
      case IngredientCategoryEnum.hat:
        return 'hạt';
      case IngredientCategoryEnum.khac:
        return 'khác';
    }
  }

  static IngredientCategoryEnum fromDbValue(String value) {
    switch (value) {
      case 'sữa':
        return IngredientCategoryEnum.sua;
      case 'thịt':
        return IngredientCategoryEnum.thit;
      case 'rau':
        return IngredientCategoryEnum.rau;
      case 'hạt':
        return IngredientCategoryEnum.hat;
      case 'khác':
        return IngredientCategoryEnum.khac;
      default:
        throw ArgumentError('Unknown ingredient category value: $value');
    }
  }
}


         
         