
class Profile {
  final String id;
  final String? name;
  final String? avatarUrl;
  final DateTime? createdAt;

  Profile({
    required this.id,
    this.name,
    this.avatarUrl,
    this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'name': name,
      'avatar_url': avatarUrl,
    };
    if (createdAt != null) {
      map['created_at'] = createdAt!.toIso8601String();
    }
    return map;
  }

  @override
  String toString() => 'Profile(id: $id, name: $name, avatarUrl: $avatarUrl, createdAt: $createdAt)';
}
