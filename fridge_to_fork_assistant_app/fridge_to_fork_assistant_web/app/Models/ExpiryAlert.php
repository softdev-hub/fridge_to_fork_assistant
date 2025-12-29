<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ExpiryAlert extends Model
{
    /**
     * Tên bảng trong database
     */
    protected $table = 'expiry_alerts';

    /**
     * Primary key
     */
    protected $primaryKey = 'alert_id';

    /**
     * Các cột có thể gán giá trị
     */
    protected $fillable = [
        'profile_id',
        'pantry_item_id',
        'alert_date',
        'is_read',
        'message',
    ];

    /**
     * Casting các cột
     */
    protected $casts = [
        'alert_date' => 'date',
        'is_read' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Quan hệ: ExpiryAlert thuộc về Profile
     */
    public function profile(): BelongsTo
    {
        return $this->belongsTo(Profile::class, 'profile_id', 'id');
    }

    /**
     * Quan hệ: ExpiryAlert thuộc về PantryItem
     */
    public function pantryItem(): BelongsTo
    {
        return $this->belongsTo(PantryItem::class, 'pantry_item_id', 'pantry_item_id');
    }

    /**
     * Scope: Lấy alerts chưa đọc
     */
    public function scopeUnread($query)
    {
        return $query->where('is_read', false);
    }
}
