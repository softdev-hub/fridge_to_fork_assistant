<?php

namespace App\Http\Controllers;

use App\Models\Ingredient;
use App\Models\PantryItem;
use App\Models\Profile;
use Carbon\Carbon;

class DashboardController extends Controller
{
    /**
     * Hiển thị trang dashboard
     */
    public function index()
    {
        // Thống kê tổng quan
        $stats = [
            'total_users' => Profile::count(),
            'total_ingredients' => Ingredient::whereNull('deleted_at')->count(),
            'total_pantry_items' => PantryItem::whereNull('deleted_at')->count(),
            'expired_items' => PantryItem::whereNull('deleted_at')
                ->whereNotNull('expiry_date')
                ->where('expiry_date', '<', Carbon::today())
                ->count(),
            'expiring_soon_items' => PantryItem::whereNull('deleted_at')
                ->whereNotNull('expiry_date')
                ->where('expiry_date', '>=', Carbon::today())
                ->where('expiry_date', '<=', Carbon::today()->addDays(3))
                ->count(),
        ];

        // Danh sách items sắp hết hạn (lấy 10 items mới nhất)
        $expiringSoonItems = PantryItem::with(['profile', 'ingredient'])
            ->whereNull('deleted_at')
            ->whereNotNull('expiry_date')
            ->where('expiry_date', '>=', Carbon::today())
            ->where('expiry_date', '<=', Carbon::today()->addDays(7))
            ->orderBy('expiry_date', 'asc')
            ->limit(10)
            ->get();

        // Danh sách items đã hết hạn (lấy 10 items mới nhất)
        $expiredItems = PantryItem::with(['profile', 'ingredient'])
            ->whereNull('deleted_at')
            ->whereNotNull('expiry_date')
            ->where('expiry_date', '<', Carbon::today())
            ->orderBy('expiry_date', 'desc')
            ->limit(10)
            ->get();

        // Thống kê theo category
        $categoryStats = Ingredient::whereNull('deleted_at')
            ->selectRaw('category, count(*) as count')
            ->groupBy('category')
            ->get()
            ->pluck('count', 'category')
            ->toArray();

        return view('dashboard', compact(
            'stats',
            'expiringSoonItems',
            'expiredItems',
            'categoryStats'
        ));
    }
}
