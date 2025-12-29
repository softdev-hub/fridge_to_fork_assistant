<?php

namespace App\Http\Controllers;

use App\Models\Ingredient;
use Illuminate\Http\Request;

class IngredientController extends Controller
{
    /**
     * Hiển thị danh sách nguyên liệu
     */
    public function index(Request $request)
    {
        $query = Ingredient::whereNull('deleted_at');

        // Tìm kiếm theo tên
        if ($request->filled('search')) {
            $query->where('name', 'ilike', '%' . $request->search . '%');
        }

        // Lọc theo category
        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }

        $ingredients = $query->orderBy('name')->paginate(20);
        $categories = Ingredient::CATEGORIES;

        return view('ingredients.index', compact('ingredients', 'categories'));
    }

    /**
     * Hiển thị form thêm nguyên liệu
     */
    public function create()
    {
        $categories = Ingredient::CATEGORIES;
        $units = Ingredient::UNITS;

        return view('ingredients.create', compact('categories', 'units'));
    }

    /**
     * Lưu nguyên liệu mới
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'category' => 'nullable|string|in:' . implode(',', Ingredient::CATEGORIES),
            'unit' => 'nullable|string|in:' . implode(',', Ingredient::UNITS),
        ]);

        // Tạo name_normalized
        $validated['name_normalized'] = $this->normalizeString($validated['name']);

        Ingredient::create($validated);

        return redirect()->route('ingredients.index')
            ->with('success', 'Đã thêm nguyên liệu thành công!');
    }

    /**
     * Hiển thị form sửa nguyên liệu
     */
    public function edit($id)
    {
        $ingredient = Ingredient::findOrFail($id);
        $categories = Ingredient::CATEGORIES;
        $units = Ingredient::UNITS;

        return view('ingredients.edit', compact('ingredient', 'categories', 'units'));
    }

    /**
     * Cập nhật nguyên liệu
     */
    public function update(Request $request, $id)
    {
        $ingredient = Ingredient::findOrFail($id);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'category' => 'nullable|string|in:' . implode(',', Ingredient::CATEGORIES),
            'unit' => 'nullable|string|in:' . implode(',', Ingredient::UNITS),
        ]);

        // Cập nhật name_normalized
        $validated['name_normalized'] = $this->normalizeString($validated['name']);

        $ingredient->update($validated);

        return redirect()->route('ingredients.index')
            ->with('success', 'Đã cập nhật nguyên liệu thành công!');
    }

    /**
     * Xóa mềm nguyên liệu
     */
    public function destroy($id)
    {
        $ingredient = Ingredient::findOrFail($id);
        $ingredient->delete();

        return redirect()->route('ingredients.index')
            ->with('success', 'Đã xóa nguyên liệu thành công!');
    }

    /**
     * Chuẩn hóa chuỗi để tìm kiếm
     */
    private function normalizeString(string $input): string
    {
        $str = mb_strtolower($input);

        // Thay thế các ký tự có dấu tiếng Việt
        $patterns = [
            '/[àáạảãâầấậẩẫăằắặẳẵ]/u' => 'a',
            '/[èéẹẻẽêềếệểễ]/u' => 'e',
            '/[ìíịỉĩ]/u' => 'i',
            '/[òóọỏõôồốộổỗơờớợởỡ]/u' => 'o',
            '/[ùúụủũưừứựửữ]/u' => 'u',
            '/[ỳýỵỷỹ]/u' => 'y',
            '/[đ]/u' => 'd',
        ];

        foreach ($patterns as $pattern => $replacement) {
            $str = preg_replace($pattern, $replacement, $str);
        }

        return preg_replace('/[^a-z0-9\s]/', '', $str);
    }
}
