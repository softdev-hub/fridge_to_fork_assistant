@extends('layouts.admin')

@section('title', 'Thêm Nguyên liệu')
@section('page-title', 'Thêm nguyên liệu mới')
@section('page-subtitle', 'Tạo nguyên liệu mới trong hệ thống')

@section('content')
    <div class="card" style="max-width: 600px;">
        <form action="{{ route('ingredients.store') }}" method="POST">
            @csrf

            <div class="form-group">
                <label class="form-label" for="name">Tên nguyên liệu *</label>
                <input type="text" name="name" id="name" class="form-input" value="{{ old('name') }}" required
                    placeholder="VD: Thịt bò, Cà chua...">
                @error('name')
                    <span style="color: var(--danger); font-size: 12px;">{{ $message }}</span>
                @enderror
            </div>

            <div class="form-group">
                <label class="form-label" for="category">Loại</label>
                <select name="category" id="category" class="form-select">
                    <option value="">-- Chọn loại --</option>
                    @foreach($categories as $category)
                        <option value="{{ $category }}" {{ old('category') == $category ? 'selected' : '' }}>
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
                        <option value="{{ $unit }}" {{ old('unit') == $unit ? 'selected' : '' }}>
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
                    ✅ Lưu nguyên liệu
                </button>
                <a href="{{ route('ingredients.index') }}" class="btn btn-secondary">
                    Hủy
                </a>
            </div>
        </form>
    </div>
@endsection