<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Recipe extends Model
{
    use SoftDeletes;

    protected $table = 'recipes';
    protected $primaryKey = 'recipe_id';

    protected $fillable = [
        'title',
        'description',
        'instructions',
        'cooking_time_minutes',
        'servings',
        'difficulty',
        'cuisine',
        'meal_type',
        'image_url',
        'video_url',
        'source_url',
    ];

    protected $casts = [
        'cooking_time_minutes' => 'integer',
        'servings' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    public const DIFFICULTIES = ['easy', 'medium', 'hard'];
    public const MEAL_TYPES = ['breakfast', 'lunch', 'dinner'];

    public function ingredients(): BelongsToMany
    {
        return $this->belongsToMany(
            Ingredient::class,
            'recipe_ingredients',
            'recipe_id',
            'ingredient_id'
        )->withPivot(['quantity', 'unit']);
    }

    public function recipeIngredients(): HasMany
    {
        return $this->hasMany(RecipeIngredient::class, 'recipe_id', 'recipe_id');
    }

    public function mealPlans(): BelongsToMany
    {
        return $this->belongsToMany(
            MealPlan::class,
            'meal_plan_recipes',
            'recipe_id',
            'meal_plan_id'
        )->withPivot(['servings', 'position']);
    }

    public function favoredByProfiles(): BelongsToMany
    {
        return $this->belongsToMany(
            Profile::class,
            'favorite_recipes',
            'recipe_id',
            'profile_id'
        )->withPivot('saved_at');
    }

    public function getDifficultyDisplayAttribute(): string
    {
        return match ($this->difficulty) {
            'easy' => 'Dễ',
            'medium' => 'Trung bình',
            'hard' => 'Khó',
            default => $this->difficulty ?? '-',
        };
    }

    public function getMealTypeDisplayAttribute(): string
    {
        return match ($this->meal_type) {
            'breakfast' => 'Bữa sáng',
            'lunch' => 'Bữa trưa',
            'dinner' => 'Bữa tối',
            default => $this->meal_type ?? '-',
        };
    }
}
