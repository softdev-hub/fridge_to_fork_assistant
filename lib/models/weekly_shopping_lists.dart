class WeeklyShoppingList {
  final int? listId; // list_id (bigserial PK)
  final String profileId; // profile_id (uuid FK -> profiles.id)
  final String? title; // title (text)
  final DateTime weekStart; // week_start (date)
  final DateTime? createdAt; // created_at (timestamptz)

  WeeklyShoppingList({
    this.listId,
    required this.profileId,
    this.title,
    required this.weekStart,
    this.createdAt,
  });

  factory WeeklyShoppingList.fromJson(Map<String, dynamic> json) {
    return WeeklyShoppingList(
      listId: json['list_id'] as int?,
      profileId: json['profile_id'] as String,
      title: json['title'] as String?,
      weekStart: DateTime.parse(json['week_start'] as String),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Full JSON (bao gồm PK) – dùng cho hiển thị/debug.
  Map<String, dynamic> toJson() {
    return {
      if (listId != null) 'list_id': listId,
      'profile_id': profileId,
      if (title != null) 'title': title,
      'week_start': weekStart.toIso8601String().split('T')[0],
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  /// JSON để insert/upsert vào Supabase (DB tự set created_at, PK).
  Map<String, dynamic> toInsertJson() {
    return {
      'profile_id': profileId,
      if (title != null) 'title': title,
      'week_start': weekStart.toIso8601String().split('T')[0],
    };
  }

  /// JSON để update record hiện có (không đổi profile_id/PK).
  Map<String, dynamic> toUpdateJson() {
    return {
      if (title != null) 'title': title,
      'week_start': weekStart.toIso8601String().split('T')[0],
    };
  }

  WeeklyShoppingList copyWith({
    int? listId,
    String? profileId,
    String? title,
    DateTime? weekStart,
    DateTime? createdAt,
  }) {
    return WeeklyShoppingList(
      listId: listId ?? this.listId,
      profileId: profileId ?? this.profileId,
      title: title ?? this.title,
      weekStart: weekStart ?? this.weekStart,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'WeeklyShoppingList(listId: $listId, profileId: $profileId, weekStart: $weekStart, title: $title)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeeklyShoppingList && other.listId == listId;
  }

  @override
  int get hashCode => listId.hashCode;
}
