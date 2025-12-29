import 'enums.dart';

class MealPlan {
  final int? mealPlanId; // meal_plan_id (bigserial PK)
  final String profileId; // profile_id (uuid FK -> profiles.id)
  final DateTime plannedDate; // planned_date (date)
  final MealTypeEnum mealType; // meal_type (meal_type_enum)
  final MealPlanStatusEnum status; // status (meal_plan_status_enum)
  final DateTime? createdAt; // created_at (timestamptz)

  MealPlan({
    this.mealPlanId,
    required this.profileId,
    required this.plannedDate,
    required this.mealType,
    this.status = MealPlanStatusEnum.planned,
    this.createdAt,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      mealPlanId: json['meal_plan_id'] as int?,
      profileId: json['profile_id'] as String,
      plannedDate: DateTime.parse(json['planned_date'] as String),
      mealType: MealTypeEnum.fromDbValue(json['meal_type'] as String),
      status: json['status'] != null
          ? MealPlanStatusEnum.fromDbValue(json['status'] as String)
          : MealPlanStatusEnum.planned,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Full JSON (bao gồm PK) – dùng cho hiển thị/debug.
  Map<String, dynamic> toJson() {
    return {
      if (mealPlanId != null) 'meal_plan_id': mealPlanId,
      'profile_id': profileId,
      'planned_date': plannedDate.toIso8601String().split('T')[0],
      'meal_type': mealType.toDbValue(),
      'status': status.toDbValue(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  /// JSON để insert/upsert vào Supabase (DB tự set created_at, PK).
  Map<String, dynamic> toInsertJson() {
    return {
      'profile_id': profileId,
      'planned_date': plannedDate.toIso8601String().split('T')[0],
      'meal_type': mealType.toDbValue(),
      'status': status.toDbValue(),
    };
  }

  /// JSON để update record hiện có (không đổi profile_id/PK).
  Map<String, dynamic> toUpdateJson() {
    return {
      'planned_date': plannedDate.toIso8601String().split('T')[0],
      'meal_type': mealType.toDbValue(),
      'status': status.toDbValue(),
    };
  }

  MealPlan copyWith({
    int? mealPlanId,
    String? profileId,
    DateTime? plannedDate,
    MealTypeEnum? mealType,
    MealPlanStatusEnum? status,
    DateTime? createdAt,
  }) {
    return MealPlan(
      mealPlanId: mealPlanId ?? this.mealPlanId,
      profileId: profileId ?? this.profileId,
      plannedDate: plannedDate ?? this.plannedDate,
      mealType: mealType ?? this.mealType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'MealPlan(mealPlanId: $mealPlanId, profileId: $profileId, plannedDate: $plannedDate, mealType: $mealType, status: $status)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealPlan && other.mealPlanId == mealPlanId;
  }

  @override
  int get hashCode => mealPlanId.hashCode;
}
