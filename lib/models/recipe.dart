import 'enums.dart';
import 'recipe_ingredient.dart';

class Recipe {
  final int? recipeId;
  final String title;
  final String? description;
  final String? instructions;
  final int? cookingTimeMinutes;
  final int? servings;
  final RecipeDifficultyEnum? difficulty;
  final String? cuisine;
  final MealTypeEnum? mealType;
  final String? imageUrl;
  final String? videoUrl;
  final String? sourceUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  /// Optional joined data
  final List<RecipeIngredient>? ingredients;

  const Recipe({
    this.recipeId,
    required this.title,
    this.description,
    this.instructions,
    this.cookingTimeMinutes,
    this.servings,
    this.difficulty,
    this.cuisine,
    this.mealType,
    this.imageUrl,
    this.videoUrl,
    this.sourceUrl,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.ingredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      recipeId: json['recipe_id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String?,
      instructions: json['instructions'] as String?,
      cookingTimeMinutes: json['cooking_time_minutes'] as int?,
      servings: json['servings'] as int?,
      difficulty: json['difficulty'] != null
          ? RecipeDifficultyEnum.fromDbValue(json['difficulty'] as String)
          : null,
      cuisine: json['cuisine'] as String?,
      mealType: json['meal_type'] != null
          ? MealTypeEnum.fromDbValue(json['meal_type'] as String)
          : null,
      imageUrl: json['image_url'] as String?,
      videoUrl: json['video_url'] as String?,
      sourceUrl: json['source_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      ingredients: json['recipe_ingredients'] != null
          ? (json['recipe_ingredients'] as List)
                .map(
                  (e) => RecipeIngredient.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (recipeId != null) 'recipe_id': recipeId,
      'title': title,
      if (description != null) 'description': description,
      if (instructions != null) 'instructions': instructions,
      if (cookingTimeMinutes != null)
        'cooking_time_minutes': cookingTimeMinutes,
      if (servings != null) 'servings': servings,
      if (difficulty != null) 'difficulty': difficulty!.toDbValue(),
      if (cuisine != null) 'cuisine': cuisine,
      if (mealType != null) 'meal_type': mealType!.toDbValue(),
      if (imageUrl != null) 'image_url': imageUrl,
      if (videoUrl != null) 'video_url': videoUrl,
      if (sourceUrl != null) 'source_url': sourceUrl,
    };
  }

  Recipe copyWith({
    int? recipeId,
    String? title,
    String? description,
    String? instructions,
    int? cookingTimeMinutes,
    int? servings,
    RecipeDifficultyEnum? difficulty,
    String? cuisine,
    MealTypeEnum? mealType,
    String? imageUrl,
    String? videoUrl,
    String? sourceUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    List<RecipeIngredient>? ingredients,
  }) {
    return Recipe(
      recipeId: recipeId ?? this.recipeId,
      title: title ?? this.title,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      cookingTimeMinutes: cookingTimeMinutes ?? this.cookingTimeMinutes,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      cuisine: cuisine ?? this.cuisine,
      mealType: mealType ?? this.mealType,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      ingredients: ingredients ?? this.ingredients,
    );
  }
}
