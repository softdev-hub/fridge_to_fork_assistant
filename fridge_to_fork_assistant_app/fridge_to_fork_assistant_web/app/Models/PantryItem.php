<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use Carbon\Carbon;

class PantryItem extends Model
{
    use SoftDeletes;

    /**
     * Tên bảng trong database
     */
    protected $table = 'pantry_items';

    /**
     * Primary key
     */
    protected $primaryKey = 'pantry_item_id';

    /**
     * Các cột có thể gán giá trị
     */
    protected $fillable = [
        'profile_id',
        'ingredient_id',
        'quantity',
        'unit',
        'purchase_date',
        'expiry_date',
        'note',
        'image_url',
    ];

    /**
     * Casting các cột
     */
    protected $casts = [
        'quantity' => 'decimal:2',
        'purchase_date' => 'date',
        'expiry_date' => 'date',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    /**
     * Quan hệ: PantryItem thuộc về Profile
     */
    public function profile(): BelongsTo
    {
        return $this->belongsTo(Profile::class, 'profile_id', 'id');
    }

    /**
     * Quan hệ: PantryItem thuộc về Ingredient
     */
    public function ingredient(): BelongsTo
    {
        return $this->belongsTo(Ingredient::class, 'ingredient_id', 'ingredient_id');
    }

    /**
     * Kiểm tra item đã hết hạn chưa
     */
    public function getIsExpiredAttribute(): bool
    {
        if (!$this->expiry_date) {
            return false;
        }
        return Carbon::today()->isAfter($this->expiry_date);
    }

    /**
     * Kiểm tra item sắp hết hạn (trong 3 ngày)
     */
    public function getIsExpiringSoonAttribute(): bool
    {
        if (!$this->expiry_date) {
            return false;
        }
        $today = Carbon::today();
        $threeDaysLater = $today->copy()->addDays(3);

        return $this->expiry_date->isAfter($today) &&
            $this->expiry_date->lessThanOrEqualTo($threeDaysLater);
    }

    /**
     * Số ngày còn lại đến hạn
     */
    public function getDaysUntilExpiryAttribute(): ?int
    {
        if (!$this->expiry_date) {
            return null;
        }
        return Carbon::today()->diffInDays($this->expiry_date, false);
    }

    /**
     * Text hiển thị trạng thái hết hạn
     */
    public function getExpiryStatusAttribute(): string
    {
        $days = $this->days_until_expiry;

        if ($days === null) {
            return 'Không có HSD';
        }

        if ($days < 0) {
            return 'Đã hết hạn ' . abs($days) . ' ngày';
        }

        if ($days === 0) {
            return 'Hết hạn hôm nay';
        }

        if ($days <= 3) {
            return 'Còn ' . $days . ' ngày';
        }

        return 'Còn ' . $days . ' ngày';
    }

    /**
     * CSS class cho trạng thái hết hạn
     */
    public function getExpiryStatusClassAttribute(): string
    {
        $days = $this->days_until_expiry;

        if ($days === null) {
            return 'status-neutral';
        }

        if ($days < 0) {
            return 'status-expired';
        }

        if ($days <= 3) {
            return 'status-warning';
        }

        return 'status-safe';
    }

    /**
     * Scope: Lấy items chưa bị xóa
     */
    public function scopeActive($query)
    {
        return $query->whereNull('deleted_at');
    }

    /**
     * Scope: Lấy items đã hết hạn
     */
    public function scopeExpired($query)
    {
        return $query->whereNotNull('expiry_date')
            ->where('expiry_date', '<', Carbon::today());
    }

    /**
     * Scope: Lấy items sắp hết hạn (trong 3 ngày)
     */
    public function scopeExpiringSoon($query)
    {
        $today = Carbon::today();
        $threeDaysLater = $today->copy()->addDays(3);

        return $query->whereNotNull('expiry_date')
            ->where('expiry_date', '>=', $today)
            ->where('expiry_date', '<=', $threeDaysLater);
    }
}
