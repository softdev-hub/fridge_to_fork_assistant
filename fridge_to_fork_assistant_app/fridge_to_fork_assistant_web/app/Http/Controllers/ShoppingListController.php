<?php

namespace App\Http\Controllers;

use App\Models\WeeklyShoppingList;
use App\Models\Profile;
use Illuminate\Http\Request;

class ShoppingListController extends Controller
{
    public function index(Request $request)
    {
        $query = WeeklyShoppingList::with(['profile'])
            ->withCount('items');

        if ($request->filled('user_id')) {
            $query->where('profile_id', $request->user_id);
        }

        $shoppingLists = $query->orderBy('week_start', 'desc')->paginate(20);
        $profiles = Profile::orderBy('name')->get();

        return view('shopping-lists.index', compact('shoppingLists', 'profiles'));
    }

    public function show($id)
    {
        $shoppingList = WeeklyShoppingList::with([
            'profile',
            'items.ingredient',
            'items.sourceRecipe'
        ])->findOrFail($id);

        return view('shopping-lists.show', compact('shoppingList'));
    }

    public function destroy($id)
    {
        $shoppingList = WeeklyShoppingList::findOrFail($id);
        $shoppingList->delete();

        return redirect()->route('shopping-lists.index')
            ->with('success', 'Đã xóa danh sách mua sắm thành công!');
    }
}
