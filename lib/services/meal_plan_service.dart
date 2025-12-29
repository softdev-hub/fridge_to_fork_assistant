import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/enums.dart';
import '../models/meal_plan.dart';
import '../models/meal_plan_recipe.dart';
import '../models/recipe.dart' as db_recipe;

/// Service làm việc với Supabase cho chức năng meal plan theo tuần.
class MealPlanService {
  MealPlanService._();

  static final MealPlanService instance = MealPlanService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Lấy danh sách công thức gợi ý cho người dùng hiện tại.
  ///
  /// Hiện tại: trả về tất cả recipes chưa bị xoá, order theo mới nhất.
  Future<List<db_recipe.Recipe>> fetchSuggestedRecipes() async {
    final response = await _supabase
        .from('recipes')
        .select()
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((e) => db_recipe.Recipe.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Lấy toàn bộ meal plans trong khoảng một tuần cho 1 profile.
  Future<List<MealPlan>> getMealPlansForWeek({
    required String profileId,
    required DateTime weekStart,
    required DateTime weekEnd,
  }) async {
    final response = await _supabase
        .from('meal_plans')
        .select()
        .eq('profile_id', profileId)
        .gte('planned_date', _formatDate(weekStart))
        .lte('planned_date', _formatDate(weekEnd));

    return (response as List<dynamic>)
        .map((e) => MealPlan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Upsert một công thức vào slot (ngày + bữa ăn).
  ///
  /// Logic:
  /// 1. Tìm hoặc tạo meal_plans cho (profile_id, planned_date, meal_type).
  /// 2. Thêm bản ghi vào meal_plan_recipes (cho phép nhiều recipe trong 1 slot).
  Future<MealPlanRecipe> addRecipeToSlot({
    required String profileId,
    required DateTime plannedDate,
    required MealTypeEnum mealType,
    required int recipeId,
    int servings = 1,
    int position = 1,
  }) async {
    final dateStr = _formatDate(plannedDate);

    // 1. Tìm hoặc tạo meal_plan
    final upsertMealPlan = await _supabase
        .from('meal_plans')
        .upsert({
          'profile_id': profileId,
          'planned_date': dateStr,
          'meal_type': mealType.toDbValue(),
        }, onConflict: 'profile_id,planned_date,meal_type')
        .select()
        .single();

    final mealPlan = MealPlan.fromJson(upsertMealPlan);

    // 2. Thêm recipe vào meal_plan_recipes
    final insertResponse = await _supabase
        .from('meal_plan_recipes')
        .insert({
          'meal_plan_id': mealPlan.mealPlanId,
          'recipe_id': recipeId,
          'servings': servings,
          'position': position,
        })
        .select()
        .single();

    return MealPlanRecipe.fromJson(insertResponse);
  }

  /// Xoá một công thức khỏi slot meal plan.
  Future<void> removeRecipeFromSlot({
    required int mealPlanId,
    required int recipeId,
  }) async {
    await _supabase
        .from('meal_plan_recipes')
        .delete()
        .eq('meal_plan_id', mealPlanId)
        .eq('recipe_id', recipeId);
  }

  String _formatDate(DateTime date) =>
      DateTime(date.year, date.month, date.day).toIso8601String().split('T')[0];
}
