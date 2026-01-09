class MealPlanRecipe {
  final int mealPlanId; // meal_plan_id (bigint FK -> meal_plans.meal_plan_id)
  final int recipeId; // recipe_id (bigint FK -> recipes.recipe_id)
  final int servings; // servings (int, default 1)
  final int position; // position (int, default 1)

  MealPlanRecipe({
    required this.mealPlanId,
    required this.recipeId,
    this.servings = 1,
    this.position = 1,
  });

  factory MealPlanRecipe.fromJson(Map<String, dynamic> json) {
    return MealPlanRecipe(
      mealPlanId: json['meal_plan_id'] as int,
      recipeId: json['recipe_id'] as int,
      servings: (json['servings'] as int?) ?? 1,
      position: (json['position'] as int?) ?? 1,
    );
  }

  /// Full JSON (bao gồm khoá chính tổng hợp).
  Map<String, dynamic> toJson() {
    return {
      'meal_plan_id': mealPlanId,
      'recipe_id': recipeId,
      'servings': servings,
      'position': position,
    };
  }

  /// JSON để insert/upsert vào Supabase.
  Map<String, dynamic> toInsertJson() {
    return {
      'meal_plan_id': mealPlanId,
      'recipe_id': recipeId,
      'servings': servings,
      'position': position,
    };
  }

  /// JSON để update record hiện có (không đổi PK).
  Map<String, dynamic> toUpdateJson() {
    return {'servings': servings, 'position': position};
  }

  MealPlanRecipe copyWith({
    int? mealPlanId,
    int? recipeId,
    int? servings,
    int? position,
  }) {
    return MealPlanRecipe(
      mealPlanId: mealPlanId ?? this.mealPlanId,
      recipeId: recipeId ?? this.recipeId,
      servings: servings ?? this.servings,
      position: position ?? this.position,
    );
  }

  @override
  String toString() =>
      'MealPlanRecipe(mealPlanId: $mealPlanId, recipeId: $recipeId, servings: $servings, position: $position)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealPlanRecipe &&
        other.mealPlanId == mealPlanId &&
        other.recipeId == recipeId;
  }

  @override
  int get hashCode => Object.hash(mealPlanId, recipeId);
}
