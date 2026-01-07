<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ShoppingListItem extends Model
{
    protected $table = 'shopping_list_items';
    protected $primaryKey = 'item_id';

    protected $fillable = [
        'list_id',
        'ingredient_id',
        'meal_plan_id',
        'source_name',
        'quantity',
        'unit',
        'is_purchased',
        'source_recipe_id',
    ];

    protected $casts = [
        'quantity' => 'decimal:3',
        'is_purchased' => 'boolean',
        'created_at' => 'datetime',
    ];

    public function shoppingList(): BelongsTo
    {
        return $this->belongsTo(WeeklyShoppingList::class, 'list_id', 'list_id');
    }

    public function ingredient(): BelongsTo
    {
        return $this->belongsTo(Ingredient::class, 'ingredient_id', 'ingredient_id');
    }

    public function mealPlan(): BelongsTo
    {
        return $this->belongsTo(MealPlan::class, 'meal_plan_id', 'meal_plan_id');
    }

    public function sourceRecipe(): BelongsTo
    {
        return $this->belongsTo(Recipe::class, 'source_recipe_id', 'recipe_id');
    }
}
