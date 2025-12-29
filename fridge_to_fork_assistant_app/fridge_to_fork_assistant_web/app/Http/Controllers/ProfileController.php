<?php

namespace App\Http\Controllers;

use App\Models\Profile;
use App\Models\PantryItem;
use Carbon\Carbon;

class ProfileController extends Controller
{
    /**
     * Hiển thị danh sách users/profiles
     */
    public function index()
    {
        $profiles = Profile::withCount([
            'pantryItems' => function ($query) {
                $query->whereNull('deleted_at');
            }
        ])->orderBy('created_at', 'desc')->paginate(20);

        return view('profiles.index', compact('profiles'));
    }

    /**
     * Hiển thị chi tiết profile và pantry items của họ
     */
    public function show($id)
    {
        $profile = Profile::findOrFail($id);

        $pantryItems = PantryItem::with('ingredient')
            ->where('profile_id', $id)
            ->whereNull('deleted_at')
            ->orderBy('expiry_date', 'asc')
            ->get();

        // Thống kê của user
        $stats = [
            'total_items' => $pantryItems->count(),
            'expired_items' => $pantryItems->filter(fn($item) => $item->is_expired)->count(),
            'expiring_soon_items' => $pantryItems->filter(fn($item) => $item->is_expiring_soon)->count(),
        ];

        return view('profiles.show', compact('profile', 'pantryItems', 'stats'));
    }
}
