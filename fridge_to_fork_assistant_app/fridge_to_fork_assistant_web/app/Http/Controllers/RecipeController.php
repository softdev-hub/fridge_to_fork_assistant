<?php

namespace App\Http\Controllers;

use App\Models\Recipe;
use App\Models\Ingredient;
use App\Models\RecipeIngredient;
use Illuminate\Http\Request;

class RecipeController extends Controller
{
    public function index(Request $request)
    {
        $query = Recipe::withCount('recipeIngredients')->whereNull('deleted_at');

        if ($request->filled('search')) {
            $query->where('title', 'ilike', '%' . $request->search . '%');
        }

        if ($request->filled('meal_type')) {
            $query->where('meal_type', $request->meal_type);
        }

        if ($request->filled('difficulty')) {
            $query->where('difficulty', $request->difficulty);
        }

        $recipes = $query->orderBy('created_at', 'desc')->paginate(20);

        return view('recipes.index', compact('recipes'));
    }

    public function create()
    {
        $ingredients = Ingredient::whereNull('deleted_at')->orderBy('name')->get();
        return view('recipes.create', compact('ingredients'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'instructions' => 'nullable|string',
            'cooking_time_minutes' => 'nullable|integer|min:1',
            'servings' => 'nullable|integer|min:1',
            'difficulty' => 'nullable|in:easy,medium,hard',
            'cuisine' => 'nullable|string|max:100',
            'meal_type' => 'nullable|in:breakfast,lunch,dinner',
            'image_url' => 'nullable|url',
            'video_url' => 'nullable|url',
            'source_url' => 'nullable|url',
        ]);

        $recipe = Recipe::create($validated);

        // Handle ingredients
        if ($request->has('ingredients')) {
            foreach ($request->ingredients as $ing) {
                if (!empty($ing['ingredient_id']) && !empty($ing['quantity'])) {
                    RecipeIngredient::create([
                        'recipe_id' => $recipe->recipe_id,
                        'ingredient_id' => $ing['ingredient_id'],
                        'quantity' => $ing['quantity'],
                        'unit' => $ing['unit'] ?? 'g',
                    ]);
                }
            }
        }

        return redirect()->route('recipes.index')
            ->with('success', 'Đã thêm công thức thành công!');
    }

    public function show($id)
    {
        $recipe = Recipe::with(['recipeIngredients.ingredient'])->findOrFail($id);
        return view('recipes.show', compact('recipe'));
    }

    public function edit($id)
    {
        $recipe = Recipe::with('recipeIngredients')->findOrFail($id);
        $ingredients = Ingredient::whereNull('deleted_at')->orderBy('name')->get();
        return view('recipes.edit', compact('recipe', 'ingredients'));
    }

    public function update(Request $request, $id)
    {
        $recipe = Recipe::findOrFail($id);

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'instructions' => 'nullable|string',
            'cooking_time_minutes' => 'nullable|integer|min:1',
            'servings' => 'nullable|integer|min:1',
            'difficulty' => 'nullable|in:easy,medium,hard',
            'cuisine' => 'nullable|string|max:100',
            'meal_type' => 'nullable|in:breakfast,lunch,dinner',
            'image_url' => 'nullable|url',
            'video_url' => 'nullable|url',
            'source_url' => 'nullable|url',
        ]);

        $recipe->update($validated);

        // Update ingredients
        RecipeIngredient::where('recipe_id', $id)->delete();
        if ($request->has('ingredients')) {
            foreach ($request->ingredients as $ing) {
                if (!empty($ing['ingredient_id']) && !empty($ing['quantity'])) {
                    RecipeIngredient::create([
                        'recipe_id' => $recipe->recipe_id,
                        'ingredient_id' => $ing['ingredient_id'],
                        'quantity' => $ing['quantity'],
                        'unit' => $ing['unit'] ?? 'g',
                    ]);
                }
            }
        }

        return redirect()->route('recipes.index')
            ->with('success', 'Đã cập nhật công thức thành công!');
    }

    public function destroy($id)
    {
        $recipe = Recipe::findOrFail($id);
        $recipe->delete();

        return redirect()->route('recipes.index')
            ->with('success', 'Đã xóa công thức thành công!');
    }
}
