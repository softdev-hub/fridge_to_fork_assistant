<?php

namespace App\Http\Controllers;

use App\Models\PantryItem;
use App\Models\Profile;
use Illuminate\Http\Request;
use Carbon\Carbon;

class PantryItemController extends Controller
{
    /**
     * Hiển thị danh sách pantry items
     */
    public function index(Request $request)
    {
        $query = PantryItem::with(['profile', 'ingredient'])
            ->whereNull('deleted_at');

        // Lọc theo trạng thái
        if ($request->filled('status')) {
            switch ($request->status) {
                case 'expired':
                    $query->whereNotNull('expiry_date')
                        ->where('expiry_date', '<', Carbon::today());
                    break;
                case 'expiring_soon':
                    $query->whereNotNull('expiry_date')
                        ->where('expiry_date', '>=', Carbon::today())
                        ->where('expiry_date', '<=', Carbon::today()->addDays(3));
                    break;
                case 'safe':
                    $query->where(function ($q) {
                        $q->whereNull('expiry_date')
                            ->orWhere('expiry_date', '>', Carbon::today()->addDays(3));
                    });
                    break;
            }
        }

        // Lọc theo user
        if ($request->filled('user_id')) {
            $query->where('profile_id', $request->user_id);
        }

        // Tìm kiếm theo tên nguyên liệu
        if ($request->filled('search')) {
            $query->whereHas('ingredient', function ($q) use ($request) {
                $q->where('name', 'ilike', '%' . $request->search . '%');
            });
        }

        $pantryItems = $query->orderBy('expiry_date', 'asc')->paginate(20);
        $profiles = Profile::orderBy('name')->get();

        // Thống kê
        $stats = [
            'total' => PantryItem::whereNull('deleted_at')->count(),
            'expired' => PantryItem::whereNull('deleted_at')
                ->whereNotNull('expiry_date')
                ->where('expiry_date', '<', Carbon::today())
                ->count(),
            'expiring_soon' => PantryItem::whereNull('deleted_at')
                ->whereNotNull('expiry_date')
                ->where('expiry_date', '>=', Carbon::today())
                ->where('expiry_date', '<=', Carbon::today()->addDays(3))
                ->count(),
        ];

        return view('pantry-items.index', compact('pantryItems', 'profiles', 'stats'));
    }

    /**
     * Hiển thị chi tiết pantry item
     */
    public function show($id)
    {
        $pantryItem = PantryItem::with(['profile', 'ingredient'])->findOrFail($id);

        return view('pantry-items.show', compact('pantryItem'));
    }

    /**
     * Xóa mềm pantry item
     */
    public function destroy($id)
    {
        $pantryItem = PantryItem::findOrFail($id);
        $pantryItem->delete();

        return redirect()->route('pantry-items.index')
            ->with('success', 'Đã xóa item thành công!');
    }
}
