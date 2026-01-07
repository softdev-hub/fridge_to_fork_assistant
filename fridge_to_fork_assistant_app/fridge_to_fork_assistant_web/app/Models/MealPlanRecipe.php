<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MealPlanRecipe extends Model
{
    protected $table = 'meal_plan_recipes';
    public $incrementing = false;
    public $timestamps = false;

    protected $fillable = [
        'meal_plan_id',
        'recipe_id',
        'servings',
        'position',
    ];

    protected $casts = [
        'servings' => 'integer',
        'position' => 'integer',
    ];

    public function mealPlan(): BelongsTo
    {
        return $this->belongsTo(MealPlan::class, 'meal_plan_id', 'meal_plan_id');
    }

    public function recipe(): BelongsTo
    {
        return $this->belongsTo(Recipe::class, 'recipe_id', 'recipe_id');
    }
}
