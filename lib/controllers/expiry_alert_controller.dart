import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expiry_alert.dart';
import '../models/pantry_item.dart';

class ExpiryAlertController {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'expiry_alerts';

  /// Get current user's profile ID
  String? get _currentProfileId => _supabase.auth.currentUser?.id;

  /// Get all alerts for the current user with joined pantry item and ingredient data
  Future<List<ExpiryAlert>> getAllAlerts() async {
    final profileId = _currentProfileId;
    if (profileId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from(_tableName)
        .select('''
          *,
          pantry_items!inner(
            *,
            ingredients(*)
          )
        ''')
        .eq('pantry_items.profile_id', profileId)
        .order('alert_date', ascending: true);

    return (response as List)
        .map((json) => ExpiryAlert.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get unsent alerts for the current user
  Future<List<ExpiryAlert>> getUnsentAlerts() async {
    final profileId = _currentProfileId;
    if (profileId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from(_tableName)
        .select('''
          *,
          pantry_items!inner(
            *,
            ingredients(*)
          )
        ''')
        .eq('pantry_items.profile_id', profileId)
        .eq('is_sent', false)
        .order('alert_date', ascending: true);

    return (response as List)
        .map((json) => ExpiryAlert.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Generate alerts for items expiring within specified days AND already expired items
  /// This checks pantry_items and creates alerts if not already existing
  Future<List<ExpiryAlert>> generateAlertsForExpiringItems({
    int daysBeforeExpiry = 3,
    int daysExpiredMax = 7, // Bao gồm items đã hết hạn trong 7 ngày qua
  }) async {
    final profileId = _currentProfileId;
    if (profileId == null) throw Exception('User not authenticated');

    // Get items expiring within the specified days AND already expired
    final today = DateTime.now();
    final futureDate = today.add(Duration(days: daysBeforeExpiry));
    final pastDate = today.subtract(Duration(days: daysExpiredMax));
    final pastDateStr = pastDate.toIso8601String().split('T')[0];
    final futureDateStr = futureDate.toIso8601String().split('T')[0];

    // Get pantry items expiring soon OR already expired (within range)
    final pantryResponse = await _supabase
        .from('pantry_items')
        .select('*, ingredients(*)')
        .eq('profile_id', profileId)
        .isFilter('deleted_at', null)
        .gte('expiry_date', pastDateStr)
        .lte('expiry_date', futureDateStr);

    final pantryItems = (pantryResponse as List)
        .map((json) => PantryItem.fromJson(json as Map<String, dynamic>))
        .toList();

    // Get existing alerts to avoid duplicates
    final existingAlerts = await getAllAlerts();
    final existingPantryItemIds = existingAlerts
        .map((a) => a.pantryItemId)
        .toSet();

    // Create new alerts for items without alerts
    final newAlerts = <ExpiryAlert>[];
    for (final item in pantryItems) {
      if (item.pantryItemId != null &&
          !existingPantryItemIds.contains(item.pantryItemId) &&
          item.expiryDate != null) {
        final alert = ExpiryAlert(
          pantryItemId: item.pantryItemId!,
          alertDate: item.expiryDate!,
        );

        try {
          final response = await _supabase
              .from(_tableName)
              .insert(alert.toInsertJson())
              .select('''
                *,
                pantry_items(
                  *,
                  ingredients(*)
                )
              ''')
              .single();

          newAlerts.add(ExpiryAlert.fromJson(response));
        } catch (e) {
          // Skip if insert fails (e.g., duplicate)
          continue;
        }
      }
    }

    return newAlerts;
  }

  /// Mark an alert as sent
  Future<void> markAlertAsSent(int alertId) async {
    await _supabase
        .from(_tableName)
        .update({'is_sent': true, 'sent_at': DateTime.now().toIso8601String()})
        .eq('alert_id', alertId);
  }

  /// Mark multiple alerts as sent
  Future<void> markAlertsAsSent(List<int> alertIds) async {
    if (alertIds.isEmpty) return;

    await _supabase
        .from(_tableName)
        .update({'is_sent': true, 'sent_at': DateTime.now().toIso8601String()})
        .inFilter('alert_id', alertIds);
  }

  /// Delete an alert
  Future<void> deleteAlert(int alertId) async {
    await _supabase.from(_tableName).delete().eq('alert_id', alertId);
  }

  /// Delete all alerts for a pantry item
  Future<void> deleteAlertsForPantryItem(int pantryItemId) async {
    await _supabase
        .from(_tableName)
        .delete()
        .eq('pantry_item_id', pantryItemId);
  }

  /// Get alert count for badge display
  Future<int> getUnsentAlertCount() async {
    final alerts = await getUnsentAlerts();
    return alerts.length;
  }

  /// Get alerts grouped by urgency category (expired, today, upcoming)
  Future<Map<String, List<ExpiryAlert>>> getAlertsGroupedByDate() async {
    final allAlerts = await getAllAlerts();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final grouped = <String, List<ExpiryAlert>>{
      'today': [], // Hết hạn hôm nay
      'yesterday': [], // Đã hết hạn (trước hôm nay)
      'older': [], // Sắp hết hạn (sau hôm nay)
    };

    for (final alert in allAlerts) {
      final alertDate = alert.alertDate;
      final alertDateOnly = DateTime(
        alertDate.year,
        alertDate.month,
        alertDate.day,
      );

      if (alertDateOnly.isBefore(today)) {
        // Đã hết hạn
        grouped['yesterday']!.add(alert);
      } else if (alertDateOnly.isAtSameMomentAs(today)) {
        // Hết hạn hôm nay
        grouped['today']!.add(alert);
      } else {
        // Sắp hết hạn (trong tương lai)
        grouped['older']!.add(alert);
      }
    }

    // Sắp xếp theo ngày hết hạn
    for (final key in grouped.keys) {
      grouped[key]!.sort((a, b) => a.alertDate.compareTo(b.alertDate));
    }

    return grouped;
  }
}
