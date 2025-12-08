import 'enums.dart';
import 'ingredient.dart';

class PantryItem {
  final int? pantryItemId;
  final String profileId;
  final int ingredientId;
  final double quantity;
  final UnitEnum unit;
  final DateTime? purchaseDate;
  final DateTime? expiryDate;
  final String? note;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  // Optional joined ingredient data
  final Ingredient? ingredient;

  PantryItem({
    this.pantryItemId,
    required this.profileId,
    required this.ingredientId,
    required this.quantity,
    required this.unit,
    this.purchaseDate,
    this.expiryDate,
    this.note,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.ingredient,
  });

  factory PantryItem.fromJson(Map<String, dynamic> json) {
    return PantryItem(
      pantryItemId: json['pantry_item_id'] as int?,
      profileId: json['profile_id'] as String,
      ingredientId: json['ingredient_id'] as int,
      quantity: (json['quantity'] as num).toDouble(),
      unit: UnitEnum.fromDbValue(json['unit'] as String),
      purchaseDate: json['purchase_date'] != null
          ? DateTime.parse(json['purchase_date'] as String)
          : null,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      note: json['note'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      ingredient: json['ingredients'] != null
          ? Ingredient.fromJson(json['ingredients'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (pantryItemId != null) 'pantry_item_id': pantryItemId,
      'profile_id': profileId,
      'ingredient_id': ingredientId,
      'quantity': quantity,
      'unit': unit.toDbValue(),
      if (purchaseDate != null)
        'purchase_date': purchaseDate!.toIso8601String().split('T')[0],
      if (expiryDate != null)
        'expiry_date': expiryDate!.toIso8601String().split('T')[0],
      if (note != null) 'note': note,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'profile_id': profileId,
      'ingredient_id': ingredientId,
      'quantity': quantity,
      'unit': unit.toDbValue(),
      if (purchaseDate != null)
        'purchase_date': purchaseDate!.toIso8601String().split('T')[0],
      if (expiryDate != null)
        'expiry_date': expiryDate!.toIso8601String().split('T')[0],
      if (note != null) 'note': note,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'ingredient_id': ingredientId,
      'quantity': quantity,
      'unit': unit.toDbValue(),
      if (purchaseDate != null)
        'purchase_date': purchaseDate!.toIso8601String().split('T')[0],
      if (expiryDate != null)
        'expiry_date': expiryDate!.toIso8601String().split('T')[0],
      if (note != null) 'note': note,
      if (imageUrl != null) 'image_url': imageUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  PantryItem copyWith({
    int? pantryItemId,
    String? profileId,
    int? ingredientId,
    double? quantity,
    UnitEnum? unit,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    String? note,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    Ingredient? ingredient,
  }) {
    return PantryItem(
      pantryItemId: pantryItemId ?? this.pantryItemId,
      profileId: profileId ?? this.profileId,
      ingredientId: ingredientId ?? this.ingredientId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      note: note ?? this.note,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      ingredient: ingredient ?? this.ingredient,
    );
  }

  /// Check if the pantry item is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  /// Check if the pantry item is expiring soon (within 3 days)
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final threeDaysFromNow = now.add(const Duration(days: 3));
    return expiryDate!.isAfter(now) && expiryDate!.isBefore(threeDaysFromNow);
  }

  /// Get days until expiry (negative if expired)
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  @override
  String toString() =>
      'PantryItem(pantryItemId: $pantryItemId, ingredientId: $ingredientId, quantity: $quantity, unit: $unit)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PantryItem && other.pantryItemId == pantryItemId;
  }

  @override
  int get hashCode => pantryItemId.hashCode;
}
