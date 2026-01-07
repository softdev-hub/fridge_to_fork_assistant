<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class MealPlan extends Model
{
    protected $table = 'meal_plans';
    protected $primaryKey = 'meal_plan_id';

    protected $fillable = [
        'profile_id',
        'planned_date',
        'meal_type',
        'status',
    ];

    protected $casts = [
        'planned_date' => 'date',
        'created_at' => 'datetime',
    ];

    public const STATUSES = ['planned', 'done', 'skipped'];
    public const MEAL_TYPES = ['breakfast', 'lunch', 'dinner'];

    public function profile(): BelongsTo
    {
        return $this->belongsTo(Profile::class, 'profile_id', 'id');
    }

    public function recipes(): BelongsToMany
    {
        return $this->belongsToMany(
            Recipe::class,
            'meal_plan_recipes',
            'meal_plan_id',
            'recipe_id'
        )->withPivot(['servings', 'position']);
    }

    public function mealPlanRecipes(): HasMany
    {
        return $this->hasMany(MealPlanRecipe::class, 'meal_plan_id', 'meal_plan_id');
    }

    public function getStatusDisplayAttribute(): string
    {
        return match ($this->status) {
            'planned' => 'Đã lên kế hoạch',
            'done' => 'Hoàn thành',
            'skipped' => 'Bỏ qua',
            default => $this->status ?? '-',
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

    public function getStatusClassAttribute(): string
    {
        return match ($this->status) {
            'planned' => 'status-warning',
            'done' => 'status-safe',
            'skipped' => 'status-neutral',
            default => 'status-neutral',
        };
    }
}
