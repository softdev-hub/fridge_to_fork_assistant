@extends('layouts.admin')

@section('title', 'Quản lý Nguyên liệu')
@section('page-title', 'Nguyên liệu')
@section('page-subtitle', 'Quản lý danh sách nguyên liệu trong hệ thống')

@section('header-actions')
    <a href="{{ route('ingredients.create') }}" class="btn btn-primary">
        ➕ Thêm nguyên liệu
    </a>
@endsection

@section('content')
    <!-- Filters -->
    <form method="GET" action="{{ route('ingredients.index') }}" class="filters">
        <div class="search-box">
            <span class="search-icon">🔍</span>
            <input type="text" name="search" placeholder="Tìm kiếm nguyên liệu..." 
                   value="{{ request('search') }}" class="form-input" style="padding-left: 44px;">
        </div>
        
        <select name="category" class="form-select" style="width: auto; min-width: 180px;">
            <option value="">Tất cả loại</option>
            @foreach($categories as $category)
                <option value="{{ $category }}" {{ request('category') == $category ? 'selected' : '' }}>
                    {{ ucfirst($category) }}
                </option>
            @endforeach
        </select>
        
        <button type="submit" class="btn btn-secondary">Lọc</button>
        
        @if(request()->hasAny(['search', 'category']))
            <a href="{{ route('ingredients.index') }}" class="btn btn-secondary">Xóa bộ lọc</a>
        @endif
    </form>

    <!-- Ingredients Table -->
    <div class="card">
        <div class="card-header">
            <h2 class="card-title">Danh sách nguyên liệu ({{ $ingredients->total() }})</h2>
        </div>

        @if($ingredients->count() > 0)
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tên</th>
                            <th>Loại</th>
                            <th>Đơn vị</th>
                            <th>Ngày tạo</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($ingredients as $ingredient)
                            <tr>
                                <td>{{ $ingredient->ingredient_id }}</td>
                                <td>
                                    <strong>{{ $ingredient->name }}</strong>
                                    @if($ingredient->name_normalized)
                                        <div style="color: var(--gray-400); font-size: 12px;">
                                            {{ $ingredient->name_normalized }}
                                        </div>
                                    @endif
                                </td>
                                <td>
                                    <span style="display: inline-flex; align-items: center; gap: 6px;">
                                        @switch($ingredient->category)
                                            @case('sữa') 🥛 @break
                                            @case('thịt') 🥩 @break
                                            @case('rau') 🥬 @break
                                            @case('hạt') 🥜 @break
                                            @default 📦
                                        @endswitch
                                        {{ $ingredient->category_display }}
                                    </span>
                                </td>
                                <td>{{ $ingredient->unit ?? '-' }}</td>
                                <td>{{ $ingredient->created_at?->format('d/m/Y') }}</td>
                                <td>
                                    <div style="display: flex; gap: 8px;">
                                        <a href="{{ route('ingredients.edit', $ingredient->ingredient_id) }}" 
                                           class="btn btn-secondary btn-sm">
                                            ✏️ Sửa
                                        </a>
                                        <form action="{{ route('ingredients.destroy', $ingredient->ingredient_id) }}" 
                                              method="POST" 
                                              onsubmit="return confirm('Bạn có chắc muốn xóa nguyên liệu này?')">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="btn btn-danger btn-sm">
                                                🗑️ Xóa
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

            <!-- Pagination -->
            <div class="pagination">
                {{ $ingredients->withQueryString()->links() }}
            </div>
        @else
            <div class="empty-state">
                <div class="empty-state-icon">🥬</div>
                <div class="empty-state-title">Chưa có nguyên liệu nào</div>
                <p>Thêm nguyên liệu mới để bắt đầu</p>
                <a href="{{ route('ingredients.create') }}" class="btn btn-primary" style="margin-top: 16px;">
                    ➕ Thêm nguyên liệu
                </a>
            </div>
        @endif
    </div>
@endsection
