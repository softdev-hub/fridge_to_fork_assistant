import 'pantry_item.dart';

class ExpiryAlert {
  final int? alertId;
  final int pantryItemId;
  final DateTime alertDate;
  final bool isSent;
  final DateTime? sentAt;
  final DateTime? createdAt;

  // Optional joined pantry item data (with ingredient)
  final PantryItem? pantryItem;

  ExpiryAlert({
    this.alertId,
    required this.pantryItemId,
    required this.alertDate,
    this.isSent = false,
    this.sentAt,
    this.createdAt,
    this.pantryItem,
  });

  factory ExpiryAlert.fromJson(Map<String, dynamic> json) {
    return ExpiryAlert(
      alertId: json['alert_id'] as int?,
      pantryItemId: json['pantry_item_id'] as int,
      alertDate: DateTime.parse(json['alert_date'] as String),
      isSent: json['is_sent'] as bool? ?? false,
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      pantryItem: json['pantry_items'] != null
          ? PantryItem.fromJson(json['pantry_items'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (alertId != null) 'alert_id': alertId,
      'pantry_item_id': pantryItemId,
      'alert_date': alertDate.toIso8601String().split('T')[0],
      'is_sent': isSent,
      if (sentAt != null) 'sent_at': sentAt!.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'pantry_item_id': pantryItemId,
      'alert_date': alertDate.toIso8601String().split('T')[0],
      'is_sent': isSent,
    };
  }

  ExpiryAlert copyWith({
    int? alertId,
    int? pantryItemId,
    DateTime? alertDate,
    bool? isSent,
    DateTime? sentAt,
    DateTime? createdAt,
    PantryItem? pantryItem,
  }) {
    return ExpiryAlert(
      alertId: alertId ?? this.alertId,
      pantryItemId: pantryItemId ?? this.pantryItemId,
      alertDate: alertDate ?? this.alertDate,
      isSent: isSent ?? this.isSent,
      sentAt: sentAt ?? this.sentAt,
      createdAt: createdAt ?? this.createdAt,
      pantryItem: pantryItem ?? this.pantryItem,
    );
  }

  /// Get the ingredient name from joined pantry item
  String get ingredientName =>
      pantryItem?.ingredient?.name ?? 'Nguyên liệu không xác định';

  /// Get days until expiry
  int get daysUntilExpiry {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(alertDate.year, alertDate.month, alertDate.day);
    return expiry.difference(today).inDays;
  }

  /// Check if the alert is for an expired item
  bool get isExpired => daysUntilExpiry < 0;

  /// Check if the alert is for today
  bool get isToday => daysUntilExpiry == 0;

  /// Get a human-readable time ago string
  String get timeAgo {
    if (createdAt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(createdAt!);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays == 1) {
      return '1 ngày trước';
    } else {
      return '${diff.inDays} ngày trước';
    }
  }

  @override
  String toString() =>
      'ExpiryAlert(alertId: $alertId, pantryItemId: $pantryItemId, alertDate: $alertDate, isSent: $isSent)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpiryAlert && other.alertId == alertId;
  }

  @override
  int get hashCode => alertId.hashCode;
}
