@extends('layouts.admin')

@section('title', 'Sửa Nguyên liệu')
@section('page-title', 'Sửa nguyên liệu')
@section('page-subtitle', 'Cập nhật thông tin nguyên liệu')

@section('content')
    <div class="card" style="max-width: 600px;">
        <form action="{{ route('ingredients.update', $ingredient->ingredient_id) }}" method="POST">
            @csrf
            @method('PUT')

            <div class="form-group">
                <label class="form-label" for="name">Tên nguyên liệu *</label>
                <input type="text" name="name" id="name" class="form-input" 
                       value="{{ old('name', $ingredient->name) }}" required>
                @error('name')
                    <span style="color: var(--danger); font-size: 12px;">{{ $message }}</span>
                @enderror
            </div>

            <div class="form-group">
                <label class="form-label" for="category">Loại</label>
                <select name="category" id="category" class="form-select">
                    <option value="">-- Chọn loại --</option>
                    @foreach($categories as $category)
                        <option value="{{ $category }}" 
                                {{ old('category', $ingredient->category) == $category ? 'selected' : '' }}>
                            {{ ucfirst($category) }}
                        </option>
                    @endforeach
                </select>
                @error('category')
                    <span style="color: var(--danger); font-size: 12px;">{{ $message }}</span>
                @enderror
            </div>

            <div class="form-group">
                <label class="form-label" for="unit">Đơn vị mặc định</label>
                <select name="unit" id="unit" class="form-select">
                    <option value="">-- Chọn đơn vị --</option>
                    @foreach($units as $unit)
                        <option value="{{ $unit }}" 
                                {{ old('unit', $ingredient->unit) == $unit ? 'selected' : '' }}>
                            {{ $unit }}
                        </option>
                    @endforeach
                </select>
                @error('unit')
                    <span style="color: var(--danger); font-size: 12px;">{{ $message }}</span>
                @enderror
            </div>

            <div style="display: flex; gap: 12px; margin-top: 24px;">
                <button type="submit" class="btn btn-primary">
                    ✅ Cập nhật
                </button>
                <a href="{{ route('ingredients.index') }}" class="btn btn-secondary">
                    Hủy
                </a>
            </div>
        </form>
    </div>
@endsection
