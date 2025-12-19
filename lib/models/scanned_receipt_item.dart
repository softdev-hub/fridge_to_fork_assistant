import 'enums.dart';

/// Represents a single item scanned from a receipt
class ScannedReceiptItem {
  final String name;
  final double quantity;
  final UnitEnum unit;
  final double? unitPrice;
  final double? totalPrice;

  ScannedReceiptItem({
    required this.name,
    required this.quantity,
    required this.unit,
    this.unitPrice,
    this.totalPrice,
  });

  /// Create a copy with optional field updates
  ScannedReceiptItem copyWith({
    String? name,
    double? quantity,
    UnitEnum? unit,
    double? unitPrice,
    double? totalPrice,
  }) {
    return ScannedReceiptItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  @override
  String toString() =>
      'ScannedReceiptItem(name: $name, quantity: $quantity, unit: ${unit.displayName})';
}
