<?php

namespace App\Http\Controllers;

use App\Models\MealPlan;
use App\Models\Profile;
use App\Models\Recipe;
use Illuminate\Http\Request;
use Carbon\Carbon;

class MealPlanController extends Controller
{
    public function index(Request $request)
    {
        $query = MealPlan::with(['profile', 'recipes']);

        if ($request->filled('user_id')) {
            $query->where('profile_id', $request->user_id);
        }

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('meal_type')) {
            $query->where('meal_type', $request->meal_type);
        }

        if ($request->filled('date_from')) {
            $query->where('planned_date', '>=', $request->date_from);
        }

        if ($request->filled('date_to')) {
            $query->where('planned_date', '<=', $request->date_to);
        }

        $mealPlans = $query->orderBy('planned_date', 'desc')
            ->orderBy('meal_type')
            ->paginate(20);

        $profiles = Profile::orderBy('name')->get();

        // Stats
        $stats = [
            'total' => MealPlan::count(),
            'planned' => MealPlan::where('status', 'planned')->count(),
            'done' => MealPlan::where('status', 'done')->count(),
            'skipped' => MealPlan::where('status', 'skipped')->count(),
        ];

        return view('meal-plans.index', compact('mealPlans', 'profiles', 'stats'));
    }

    public function show($id)
    {
        $mealPlan = MealPlan::with(['profile', 'recipes.recipeIngredients.ingredient'])->findOrFail($id);
        return view('meal-plans.show', compact('mealPlan'));
    }

    public function destroy($id)
    {
        $mealPlan = MealPlan::findOrFail($id);
        $mealPlan->delete();

        return redirect()->route('meal-plans.index')
            ->with('success', 'Đã xóa kế hoạch ăn thành công!');
    }
}
