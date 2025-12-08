import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pantry_item.dart';

class PantryItemController {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'pantry_items';

  /// Get current user's profile ID
  String? get _currentProfileId => _supabase.auth.currentUser?.id;

  /// Get all pantry items for the current user (with joined ingredients)
  Future<List<PantryItem>> getAllPantryItems() async {
    final profileId = _currentProfileId;
    if (profileId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from(_tableName)
        .select('*, ingredients(*)')
        .eq('profile_id', profileId)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => PantryItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get pantry item by ID
  Future<PantryItem?> getPantryItemById(int pantryItemId) async {
    final response = await _supabase
        .from(_tableName)
        .select('*, ingredients(*)')
        .eq('pantry_item_id', pantryItemId)
        .isFilter('deleted_at', null)
        .maybeSingle();

    if (response == null) return null;
    return PantryItem.fromJson(response);
  }

  /// Get pantry items by ingredient ID
  Future<List<PantryItem>> getPantryItemsByIngredient(int ingredientId) async {
    final profileId = _currentProfileId;
    if (profileId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from(_tableName)
        .select('*, ingredients(*)')
        .eq('profile_id', profileId)
        .eq('ingredient_id', ingredientId)
        .isFilter('deleted_at', null)
        .order('expiry_date');

    return (response as List)
        .map((json) => PantryItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get expired pantry items
  Future<List<PantryItem>> getExpiredItems() async {
    final profileId = _currentProfileId;
    if (profileId == null) throw Exception('User not authenticated');

    final today = DateTime.now().toIso8601String().split('T')[0];

    final response = await _supabase
        .from(_tableName)
        .select('*, ingredients(*)')
        .eq('profile_id', profileId)
        .isFilter('deleted_at', null)
        .lt('expiry_date', today)
        .order('expiry_date');

    return (response as List)
        .map((json) => PantryItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get items expiring soon (within specified days)
  Future<List<PantryItem>> getExpiringSoonItems({int days = 3}) async {
    final profileId = _currentProfileId;
    if (profileId == null) throw Exception('User not authenticated');

    final today = DateTime.now();
    final futureDate = today.add(Duration(days: days));
    final todayStr = today.toIso8601String().split('T')[0];
    final futureDateStr = futureDate.toIso8601String().split('T')[0];

    final response = await _supabase
        .from(_tableName)
        .select('*, ingredients(*)')
        .eq('profile_id', profileId)
        .isFilter('deleted_at', null)
        .gte('expiry_date', todayStr)
        .lte('expiry_date', futureDateStr)
        .order('expiry_date');

    return (response as List)
        .map((json) => PantryItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Search pantry items by ingredient name
  Future<List<PantryItem>> searchPantryItems(String query) async {
    final profileId = _currentProfileId;
    if (profileId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from(_tableName)
        .select('*, ingredients!inner(*)')
        .eq('profile_id', profileId)
        .isFilter('deleted_at', null)
        .ilike('ingredients.name', '%$query%')
        .order('created_at', ascending: false)
        .limit(50);

    return (response as List)
        .map((json) => PantryItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Create a new pantry item
  Future<PantryItem> createPantryItem(PantryItem pantryItem) async {
    final profileId = _currentProfileId;
    if (profileId == null) throw Exception('User not authenticated');

    // Ensure profile_id is set to current user
    final itemToInsert = pantryItem.copyWith(profileId: profileId);

    final response = await _supabase
        .from(_tableName)
        .insert(itemToInsert.toInsertJson())
        .select('*, ingredients(*)')
        .single();

    return PantryItem.fromJson(response);
  }

  /// Update an existing pantry item
  Future<PantryItem> updatePantryItem(PantryItem pantryItem) async {
    if (pantryItem.pantryItemId == null) {
      throw ArgumentError('Pantry item ID is required for update');
    }

    final response = await _supabase
        .from(_tableName)
        .update(pantryItem.toUpdateJson())
        .eq('pantry_item_id', pantryItem.pantryItemId!)
        .select('*, ingredients(*)')
        .single();

    return PantryItem.fromJson(response);
  }

  /// Update quantity of a pantry item
  Future<PantryItem> updateQuantity(
    int pantryItemId,
    double newQuantity,
  ) async {
    final response = await _supabase
        .from(_tableName)
        .update({
          'quantity': newQuantity,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('pantry_item_id', pantryItemId)
        .select('*, ingredients(*)')
        .single();

    return PantryItem.fromJson(response);
  }

  /// Soft delete a pantry item
  Future<void> deletePantryItem(int pantryItemId) async {
    await _supabase
        .from(_tableName)
        .update({
          'deleted_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('pantry_item_id', pantryItemId);
  }

  /// Hard delete a pantry item (use with caution)
  Future<void> hardDeletePantryItem(int pantryItemId) async {
    await _supabase
        .from(_tableName)
        .delete()
        .eq('pantry_item_id', pantryItemId);
  }

  /// Bulk soft delete pantry items
  Future<void> bulkDeletePantryItems(List<int> pantryItemIds) async {
    await _supabase
        .from(_tableName)
        .update({
          'deleted_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .inFilter('pantry_item_id', pantryItemIds);
  }

  /// Get summary statistics for pantry
  Future<Map<String, dynamic>> getPantrySummary() async {
    final profileId = _currentProfileId;
    if (profileId == null) throw Exception('User not authenticated');

    final allItems = await getAllPantryItems();
    final expiredItems = allItems.where((item) => item.isExpired).toList();
    final expiringSoonItems = allItems
        .where((item) => item.isExpiringSoon)
        .toList();

    return {
      'totalItems': allItems.length,
      'expiredCount': expiredItems.length,
      'expiringSoonCount': expiringSoonItems.length,
      'expiredItems': expiredItems,
      'expiringSoonItems': expiringSoonItems,
    };
  }

  /// Check if ingredient exists in pantry
  Future<bool> hasIngredientInPantry(int ingredientId) async {
    final items = await getPantryItemsByIngredient(ingredientId);
    return items.isNotEmpty;
  }

  /// Get total quantity of an ingredient in pantry
  Future<double> getTotalQuantityOfIngredient(int ingredientId) async {
    final items = await getPantryItemsByIngredient(ingredientId);
    return items.fold<double>(0.0, (sum, item) => sum + item.quantity);
  }
}
