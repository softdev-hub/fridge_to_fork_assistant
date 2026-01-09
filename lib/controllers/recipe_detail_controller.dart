import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/recipe.dart';

/// Controller phục vụ màn chi tiết công thức:
/// - Lấy công thức theo recipe_id
/// - Lấy kèm danh sách recipe_ingredients và ingredients
class RecipeDetailController {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _recipesTable = 'recipes';

  /// Lấy chi tiết công thức kèm nguyên liệu (recipe_ingredients + ingredients)
  Future<Recipe?> getRecipeDetail(int recipeId) async {
    final res = await _supabase
        .from(_recipesTable)
        .select('''
          *,
          recipe_ingredients(
            *,
            ingredients(*)
          )
        ''')
        .eq('recipe_id', recipeId)
        .maybeSingle();

    if (res == null) return null;
    return Recipe.fromJson(res);
  }

  /// Lấy danh sách công thức (không join) theo IDs
  Future<List<Recipe>> getRecipesByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final res = await _supabase
        .from(_recipesTable)
        .select()
        .inFilter('recipe_id', ids)
        .isFilter('deleted_at', null);

    return (res as List)
        .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

