<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Profile extends Model
{
    /**
     * Tên bảng trong database
     */
    protected $table = 'profiles';

    /**
     * Primary key
     */
    protected $primaryKey = 'id';

    /**
     * Primary key là UUID string, không phải auto-increment
     */
    public $incrementing = false;
    protected $keyType = 'string';

    /**
     * Các cột có thể gán giá trị
     */
    protected $fillable = [
        'id',
        'name',
        'avatar_url',
    ];

    /**
     * Casting các cột
     */
    protected $casts = [
        'created_at' => 'datetime',
    ];

    /**
     * Quan hệ: Profile có nhiều PantryItem
     */
    public function pantryItems(): HasMany
    {
        return $this->hasMany(PantryItem::class, 'profile_id', 'id');
    }

    /**
     * Quan hệ: Profile có nhiều ExpiryAlert
     */
    public function expiryAlerts(): HasMany
    {
        return $this->hasMany(ExpiryAlert::class, 'profile_id', 'id');
    }

    /**
     * Đếm số pantry items của profile
     */
    public function getPantryItemsCountAttribute(): int
    {
        return $this->pantryItems()->whereNull('deleted_at')->count();
    }
}
