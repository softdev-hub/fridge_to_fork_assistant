@extends('layouts.admin')

@section('title', 'Sửa Công thức')
@section('page-title', 'Sửa công thức')
@section('page-subtitle', $recipe->title)

@section('content')
    <div class="card">
        <form action="{{ route('recipes.update', $recipe->recipe_id) }}" method="POST">
            @csrf
            @method('PUT')

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
                <div>
                    <div class="form-group">
                        <label class="form-label" for="title">Tên công thức *</label>
                        <input type="text" name="title" id="title" class="form-input"
                            value="{{ old('title', $recipe->title) }}" required>
                        @error('title')
                            <span style="color: var(--danger); font-size: 12px;">{{ $message }}</span>
                        @enderror
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="description">Mô tả</label>
                        <textarea name="description" id="description" class="form-input"
                            rows="3">{{ old('description', $recipe->description) }}</textarea>
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                        <div class="form-group">
                            <label class="form-label" for="cooking_time_minutes">Thời gian nấu (phút)</label>
                            <input type="number" name="cooking_time_minutes" id="cooking_time_minutes" class="form-input"
                                value="{{ old('cooking_time_minutes', $recipe->cooking_time_minutes) }}" min="1">
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="servings">Khẩu phần</label>
                            <input type="number" name="servings" id="servings" class="form-input"
                                value="{{ old('servings', $recipe->servings) }}" min="1">
                        </div>
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                        <div class="form-group">
                            <label class="form-label" for="meal_type">Bữa ăn</label>
                            <select name="meal_type" id="meal_type" class="form-select">
                                <option value="">-- Chọn --</option>
                                <option value="breakfast" {{ old('meal_type', $recipe->meal_type) == 'breakfast' ? 'selected' : '' }}>Bữa sáng</option>
                                <option value="lunch" {{ old('meal_type', $recipe->meal_type) == 'lunch' ? 'selected' : '' }}>
                                    Bữa trưa</option>
                                <option value="dinner" {{ old('meal_type', $recipe->meal_type) == 'dinner' ? 'selected' : '' }}>Bữa tối</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="difficulty">Độ khó</label>
                            <select name="difficulty" id="difficulty" class="form-select">
                                <option value="">-- Chọn --</option>
                                <option value="easy" {{ old('difficulty', $recipe->difficulty) == 'easy' ? 'selected' : '' }}>
                                    Dễ</option>
                                <option value="medium" {{ old('difficulty', $recipe->difficulty) == 'medium' ? 'selected' : '' }}>Trung bình</option>
                                <option value="hard" {{ old('difficulty', $recipe->difficulty) == 'hard' ? 'selected' : '' }}>
                                    Khó</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="cuisine">Ẩm thực</label>
                        <input type="text" name="cuisine" id="cuisine" class="form-input"
                            value="{{ old('cuisine', $recipe->cuisine) }}">
                    </div>
                </div>

                <div>
                    <div class="form-group">
                        <label class="form-label" for="instructions">Hướng dẫn nấu</label>
                        <textarea name="instructions" id="instructions" class="form-input"
                            rows="10">{{ old('instructions', $recipe->instructions) }}</textarea>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="image_url">URL hình ảnh</label>
                        <input type="url" name="image_url" id="image_url" class="form-input"
                            value="{{ old('image_url', $recipe->image_url) }}">
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="video_url">URL video</label>
                        <input type="url" name="video_url" id="video_url" class="form-input"
                            value="{{ old('video_url', $recipe->video_url) }}">
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="source_url">URL nguồn</label>
                        <input type="url" name="source_url" id="source_url" class="form-input"
                            value="{{ old('source_url', $recipe->source_url) }}">
                    </div>
                </div>
            </div>

            <div
                style="display: flex; gap: 12px; margin-top: 24px; padding-top: 24px; border-top: 1px solid var(--gray-100);">
                <button type="submit" class="btn btn-primary">
                    ✅ Cập nhật
                </button>
                <a href="{{ route('recipes.index') }}" class="btn btn-secondary">
                    Hủy
                </a>
            </div>
        </form>
    </div>
@endsection