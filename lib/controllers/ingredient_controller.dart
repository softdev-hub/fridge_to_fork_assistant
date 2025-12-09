import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ingredient.dart';

class IngredientController {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'ingredients';

  /// Get all ingredients (excluding soft-deleted)
  Future<List<Ingredient>> getAllIngredients() async {
    final response = await _supabase
        .from(_tableName)
        .select()
        .isFilter('deleted_at', null)
        .order('name');

    return (response as List)
        .map((json) => Ingredient.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get ingredient by ID
  Future<Ingredient?> getIngredientById(int ingredientId) async {
    final response = await _supabase
        .from(_tableName)
        .select()
        .eq('ingredient_id', ingredientId)
        .isFilter('deleted_at', null)
        .maybeSingle();

    if (response == null) return null;
    return Ingredient.fromJson(response);
  }

  /// Get ingredient by name
  Future<Ingredient?> getIngredientByName(String name) async {
    final response = await _supabase
        .from(_tableName)
        .select()
        .eq('name', name)
        .isFilter('deleted_at', null)
        .maybeSingle();

    if (response == null) return null;
    return Ingredient.fromJson(response);
  }

  /// Search ingredients by name
  Future<List<Ingredient>> searchIngredients(String query) async {
    final response = await _supabase
        .from(_tableName)
        .select()
        .isFilter('deleted_at', null)
        .ilike('name', '%$query%')
        .order('name')
        .limit(50);

    return (response as List)
        .map((json) => Ingredient.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get ingredients by category
  Future<List<Ingredient>> getIngredientsByCategory(String category) async {
    final response = await _supabase
        .from(_tableName)
        .select()
        .eq('category', category)
        .isFilter('deleted_at', null)
        .order('name');

    return (response as List)
        .map((json) => Ingredient.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Create a new ingredient
  Future<Ingredient> createIngredient(Ingredient ingredient) async {
    final response = await _supabase
        .from(_tableName)
        .insert(ingredient.toInsertJson())
        .select()
        .single();

    return Ingredient.fromJson(response);
  }

  /// Update an existing ingredient
  Future<Ingredient> updateIngredient(Ingredient ingredient) async {
    if (ingredient.ingredientId == null) {
      throw ArgumentError('Ingredient ID is required for update');
    }

    final response = await _supabase
        .from(_tableName)
        .update(ingredient.toUpdateJson())
        .eq('ingredient_id', ingredient.ingredientId!)
        .select()
        .single();

    return Ingredient.fromJson(response);
  }

  /// Soft delete an ingredient
  Future<void> deleteIngredient(int ingredientId) async {
    await _supabase
        .from(_tableName)
        .update({
          'deleted_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('ingredient_id', ingredientId);
  }

  /// Hard delete an ingredient (use with caution)
  Future<void> hardDeleteIngredient(int ingredientId) async {
    await _supabase.from(_tableName).delete().eq('ingredient_id', ingredientId);
  }

  /// Get or create ingredient by name
  Future<Ingredient> getOrCreateIngredient(
    String name, {
    String? category,
  }) async {
    // First try to find existing ingredient
    final existing = await getIngredientByName(name);
    if (existing != null) return existing;

    // Create new ingredient if not found
    final newIngredient = Ingredient(
      name: name,
      category: category,
      nameNormalized: _normalizeString(name),
    );
    return createIngredient(newIngredient);
  }

  /// Normalize string for searching
  String _normalizeString(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
        .replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e')
        .replaceAll(RegExp(r'[ìíịỉĩ]'), 'i')
        .replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
        .replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u')
        .replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y')
        .replaceAll(RegExp(r'[đ]'), 'd')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .trim();
  }
}
