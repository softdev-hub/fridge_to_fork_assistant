import 'enums.dart';

class Ingredient {
  final int? ingredientId;
  final String name;
  final String? category;
  final UnitEnum? unit;
  final String? nameNormalized;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  Ingredient({
    this.ingredientId,
    required this.name,
    this.category,
    this.unit,
    this.nameNormalized,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      ingredientId: json['ingredient_id'] as int?,
      name: json['name'] as String,
      category: json['category'] as String?,
      unit: json['unit'] != null
          ? UnitEnum.fromDbValue(json['unit'] as String)
          : null,
      nameNormalized: json['name_normalized'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (ingredientId != null) 'ingredient_id': ingredientId,
      'name': name,
      if (category != null) 'category': category,
      if (unit != null) 'unit': unit!.toDbValue(),
      if (nameNormalized != null) 'name_normalized': nameNormalized,
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      if (category != null) 'category': category,
      if (unit != null) 'unit': unit!.toDbValue(),
      if (nameNormalized != null) 'name_normalized': nameNormalized,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      if (category != null) 'category': category,
      if (unit != null) 'unit': unit!.toDbValue(),
      if (nameNormalized != null) 'name_normalized': nameNormalized,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Ingredient copyWith({
    int? ingredientId,
    String? name,
    String? category,
    UnitEnum? unit,
    String? nameNormalized,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Ingredient(
      ingredientId: ingredientId ?? this.ingredientId,
      name: name ?? this.name,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      nameNormalized: nameNormalized ?? this.nameNormalized,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  String toString() =>
      'Ingredient(ingredientId: $ingredientId, name: $name, category: $category, unit: $unit)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ingredient && other.ingredientId == ingredientId;
  }

  @override
  int get hashCode => ingredientId.hashCode;
}
