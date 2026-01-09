class FavoriteRecipe {
  final String profileId;
  final int recipeId;
  final DateTime? savedAt;

  const FavoriteRecipe({
    required this.profileId,
    required this.recipeId,
    this.savedAt,
  });

  factory FavoriteRecipe.fromJson(Map<String, dynamic> json) {
    return FavoriteRecipe(
      profileId: json['profile_id'] as String,
      recipeId: json['recipe_id'] as int,
      savedAt: json['saved_at'] != null
          ? DateTime.parse(json['saved_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_id': profileId,
      'recipe_id': recipeId,
      if (savedAt != null) 'saved_at': savedAt!.toIso8601String(),
    };
  }
}
