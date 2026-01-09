class UserRecipeMatch {
  final int? matchId;
  final String profileId;
  final int recipeId;
  final int? totalIngredients;
  final int? availableIngredients;
  final int? missingIngredients;

  const UserRecipeMatch({
    this.matchId,
    required this.profileId,
    required this.recipeId,
    this.totalIngredients,
    this.availableIngredients,
    this.missingIngredients,
  });

  factory UserRecipeMatch.fromJson(Map<String, dynamic> json) {
    return UserRecipeMatch(
      matchId: json['match_id'] as int?,
      profileId: json['profile_id'] as String,
      recipeId: json['recipe_id'] as int,
      totalIngredients: json['total_ingredients'] as int?,
      availableIngredients: json['available_ingredients'] as int?,
      missingIngredients: json['missing_ingredients'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (matchId != null) 'match_id': matchId,
      'profile_id': profileId,
      'recipe_id': recipeId,
      if (totalIngredients != null) 'total_ingredients': totalIngredients,
      if (availableIngredients != null)
        'available_ingredients': availableIngredients,
      if (missingIngredients != null) 'missing_ingredients': missingIngredients,
    };
  }
}
