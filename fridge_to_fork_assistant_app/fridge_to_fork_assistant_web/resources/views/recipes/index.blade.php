@extends('layouts.admin')

@section('title', 'Quản lý Công thức')
@section('page-title', 'Công thức nấu ăn')
@section('page-subtitle', 'Quản lý các công thức trong hệ thống')

@section('header-actions')
    <a href="{{ route('recipes.create') }}" class="btn btn-primary">
        ➕ Thêm công thức
    </a>
@endsection

@section('content')
    <!-- Filters -->
    <form method="GET" action="{{ route('recipes.index') }}" class="filters">
        <div class="search-box">
            <span class="search-icon">🔍</span>
            <input type="text" name="search" placeholder="Tìm kiếm công thức..." value="{{ request('search') }}"
                class="form-input" style="padding-left: 44px;">
        </div>

        <select name="meal_type" class="form-select" style="width: auto; min-width: 150px;">
            <option value="">Tất cả bữa</option>
            <option value="breakfast" {{ request('meal_type') == 'breakfast' ? 'selected' : '' }}>Bữa sáng</option>
            <option value="lunch" {{ request('meal_type') == 'lunch' ? 'selected' : '' }}>Bữa trưa</option>
            <option value="dinner" {{ request('meal_type') == 'dinner' ? 'selected' : '' }}>Bữa tối</option>
        </select>

        <select name="difficulty" class="form-select" style="width: auto; min-width: 150px;">
            <option value="">Tất cả độ khó</option>
            <option value="easy" {{ request('difficulty') == 'easy' ? 'selected' : '' }}>Dễ</option>
            <option value="medium" {{ request('difficulty') == 'medium' ? 'selected' : '' }}>Trung bình</option>
            <option value="hard" {{ request('difficulty') == 'hard' ? 'selected' : '' }}>Khó</option>
        </select>

        <button type="submit" class="btn btn-secondary">Lọc</button>

        @if(request()->hasAny(['search', 'meal_type', 'difficulty']))
            <a href="{{ route('recipes.index') }}" class="btn btn-secondary">Xóa bộ lọc</a>
        @endif
    </form>

    <!-- Recipes Table -->
    <div class="card">
        <div class="card-header">
            <h2 class="card-title">Danh sách công thức ({{ $recipes->total() }})</h2>
        </div>

        @if($recipes->count() > 0)
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Hình</th>
                            <th>Tên công thức</th>
                            <th>Bữa</th>
                            <th>Độ khó</th>
                            <th>Thời gian</th>
                            <th>Nguyên liệu</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($recipes as $recipe)
                            <tr>
                                <td>
                                    @if($recipe->image_url)
                                        <img src="{{ $recipe->image_url }}" alt="" class="item-image">
                                    @else
                                        <div class="item-image" style="display: flex; align-items: center; justify-content: center;">
                                            🍳
                                        </div>
                                    @endif
                                </td>
                                <td>
                                    <strong>{{ $recipe->title }}</strong>
                                    @if($recipe->cuisine)
                                        <div style="color: var(--gray-400); font-size: 12px;">
                                            {{ $recipe->cuisine }}
                                        </div>
                                    @endif
                                </td>
                                <td>
                                    <span class="status-badge status-neutral">
                                        {{ $recipe->meal_type_display }}
                                    </span>
                                </td>
                                <td>
                                    @php
                                        $diffClass = match ($recipe->difficulty) {
                                            'easy' => 'status-safe',
                                            'medium' => 'status-warning',
                                            'hard' => 'status-expired',
                                            default => 'status-neutral'
                                        };
                                    @endphp
                                    <span class="status-badge {{ $diffClass }}">
                                        {{ $recipe->difficulty_display }}
                                    </span>
                                </td>
                                <td>{{ $recipe->cooking_time_minutes ? $recipe->cooking_time_minutes . ' phút' : '-' }}</td>
                                <td>{{ $recipe->recipe_ingredients_count }} nguyên liệu</td>
                                <td>
                                    <div style="display: flex; gap: 8px;">
                                        <a href="{{ route('recipes.show', $recipe->recipe_id) }}"
                                            class="btn btn-secondary btn-sm">👁️</a>
                                        <a href="{{ route('recipes.edit', $recipe->recipe_id) }}"
                                            class="btn btn-secondary btn-sm">✏️</a>
                                        <form action="{{ route('recipes.destroy', $recipe->recipe_id) }}" method="POST"
                                            onsubmit="return confirm('Bạn có chắc muốn xóa công thức này?')">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="btn btn-danger btn-sm">🗑️</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

            <div class="pagination">
                {{ $recipes->withQueryString()->links() }}
            </div>
        @else
            <div class="empty-state">
                <div class="empty-state-icon">📖</div>
                <div class="empty-state-title">Chưa có công thức nào</div>
                <p>Thêm công thức mới để bắt đầu</p>
                <a href="{{ route('recipes.create') }}" class="btn btn-primary" style="margin-top: 16px;">
                    ➕ Thêm công thức
                </a>
            </div>
        @endif
    </div>
@endsection