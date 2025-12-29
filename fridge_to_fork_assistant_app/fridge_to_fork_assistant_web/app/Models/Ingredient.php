<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Ingredient extends Model
{
    use SoftDeletes;

    /**
     * Tên bảng trong database
     */
    protected $table = 'ingredients';

    /**
     * Primary key
     */
    protected $primaryKey = 'ingredient_id';

    /**
     * Các cột có thể gán giá trị
     */
    protected $fillable = [
        'name',
        'category',
        'unit',
        'name_normalized',
    ];

    /**
     * Casting các cột
     */
    protected $casts = [
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    /**
     * Các giá trị unit hợp lệ
     */
    public const UNITS = ['g', 'ml', 'cái', 'quả'];

    /**
     * Các giá trị category hợp lệ
     */
    public const CATEGORIES = ['sữa', 'thịt', 'rau', 'hạt', 'khác'];

    /**
     * Quan hệ: Ingredient có nhiều PantryItem
     */
    public function pantryItems(): HasMany
    {
        return $this->hasMany(PantryItem::class, 'ingredient_id', 'ingredient_id');
    }

    /**
     * Lấy tên hiển thị của unit
     */
    public function getUnitDisplayAttribute(): string
    {
        return $this->unit ?? '';
    }

    /**
     * Lấy tên hiển thị của category
     */
    public function getCategoryDisplayAttribute(): string
    {
        return match ($this->category) {
            'sữa' => 'Sữa',
            'thịt' => 'Thịt',
            'rau' => 'Rau',
            'hạt' => 'Hạt',
            'khác' => 'Khác',
            default => $this->category ?? 'Chưa phân loại',
        };
    }
}
