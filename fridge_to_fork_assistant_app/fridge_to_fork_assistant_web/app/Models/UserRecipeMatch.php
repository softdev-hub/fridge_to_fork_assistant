<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserRecipeMatch extends Model
{
    protected $table = 'user_recipe_matches';
    protected $primaryKey = 'match_id';
    public $timestamps = false;

    protected $fillable = [
        'profile_id',
        'recipe_id',
        'total_ingredients',
        'available_ingredients',
        'missing_ingredients',
    ];

    protected $casts = [
        'total_ingredients' => 'integer',
        'available_ingredients' => 'integer',
        'missing_ingredients' => 'integer',
    ];

    public function profile(): BelongsTo
    {
        return $this->belongsTo(Profile::class, 'profile_id', 'id');
    }

    public function recipe(): BelongsTo
    {
        return $this->belongsTo(Recipe::class, 'recipe_id', 'recipe_id');
    }

    public function getMatchPercentAttribute(): int
    {
        if ($this->total_ingredients === 0)
            return 0;
        return (int) round(($this->available_ingredients / $this->total_ingredients) * 100);
    }
}
