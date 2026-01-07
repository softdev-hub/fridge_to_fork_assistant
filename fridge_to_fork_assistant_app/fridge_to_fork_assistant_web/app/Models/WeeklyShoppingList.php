<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class WeeklyShoppingList extends Model
{
    protected $table = 'weekly_shopping_lists';
    protected $primaryKey = 'list_id';

    protected $fillable = [
        'profile_id',
        'title',
        'week_start',
    ];

    protected $casts = [
        'week_start' => 'date',
        'created_at' => 'datetime',
    ];

    public function profile(): BelongsTo
    {
        return $this->belongsTo(Profile::class, 'profile_id', 'id');
    }

    public function items(): HasMany
    {
        return $this->hasMany(ShoppingListItem::class, 'list_id', 'list_id');
    }

    public function getTotalItemsAttribute(): int
    {
        return $this->items()->count();
    }

    public function getPurchasedItemsAttribute(): int
    {
        return $this->items()->where('is_purchased', true)->count();
    }

    public function getProgressPercentAttribute(): int
    {
        $total = $this->total_items;
        if ($total === 0)
            return 0;
        return (int) round(($this->purchased_items / $total) * 100);
    }
}
