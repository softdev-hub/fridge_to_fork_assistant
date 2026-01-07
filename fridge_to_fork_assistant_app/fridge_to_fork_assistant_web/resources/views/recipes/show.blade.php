@extends('layouts.admin')

@section('title', 'Chi tiết Công thức')
@section('page-title', $recipe->title)
@section('page-subtitle', 'Chi tiết công thức nấu ăn')

@section('header-actions')
    <div style="display: flex; gap: 12px;">
        <a href="{{ route('recipes.edit', $recipe->recipe_id) }}" class="btn btn-secondary">
            ✏️ Chỉnh sửa
        </a>
        <a href="{{ route('recipes.index') }}" class="btn btn-secondary">
            ← Quay lại
        </a>
    </div>
@endsection

@section('content')
    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
        <!-- Thông tin công thức -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title">📖 Thông tin</h2>
            </div>

            @if($recipe->image_url)
                <div style="margin-bottom: 20px;">
                    <img src="{{ $recipe->image_url }}" alt="{{ $recipe->title }}"
                        style="width: 100%; max-height: 300px; object-fit: cover; border-radius: 12px;">
                </div>
            @endif

            <div style="display: grid; gap: 16px;">
                <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 12px;">
                    <div style="text-align: center; padding: 12px; background: var(--gray-50); border-radius: 8px;">
                        <div style="font-size: 11px; color: var(--gray-500);">Thời gian</div>
                        <div style="font-weight: 600;">{{ $recipe->cooking_time_minutes ?? '-' }} phút</div>
                    </div>
                    <div style="text-align: center; padding: 12px; background: var(--gray-50); border-radius: 8px;">
                        <div style="font-size: 11px; color: var(--gray-500);">Khẩu phần</div>
                        <div style="font-weight: 600;">{{ $recipe->servings ?? '-' }} người</div>
                    </div>
                    <div style="text-align: center; padding: 12px; background: var(--gray-50); border-radius: 8px;">
                        <div style="font-size: 11px; color: var(--gray-500);">Độ khó</div>
                        <div style="font-weight: 600;">{{ $recipe->difficulty_display }}</div>
                    </div>
                </div>

                @if($recipe->description)
                    <div>
                        <div style="color: var(--gray-500); font-size: 12px; margin-bottom: 4px;">Mô tả</div>
                        <div>{{ $recipe->description }}</div>
                    </div>
                @endif

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                    <div>
                        <div style="color: var(--gray-500); font-size: 12px; margin-bottom: 4px;">Bữa</div>
                        <div style="font-weight: 600;">{{ $recipe->meal_type_display }}</div>
                    </div>
                    <div>
                        <div style="color: var(--gray-500); font-size: 12px; margin-bottom: 4px;">Ẩm thực</div>
                        <div style="font-weight: 600;">{{ $recipe->cuisine ?? '-' }}</div>
                    </div>
                </div>

                @if($recipe->source_url)
                    <div>
                        <div style="color: var(--gray-500); font-size: 12px; margin-bottom: 4px;">Nguồn</div>
                        <a href="{{ $recipe->source_url }}" target="_blank" style="color: var(--primary);">
                            {{ $recipe->source_url }}
                        </a>
                    </div>
                @endif
            </div>
        </div>

        <!-- Nguyên liệu -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title">🥬 Nguyên liệu ({{ $recipe->recipeIngredients->count() }})</h2>
            </div>

            @if($recipe->recipeIngredients->count() > 0)
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Nguyên liệu</th>
                                <th>Số lượng</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($recipe->recipeIngredients as $ri)
                                <tr>
                                    <td>{{ $ri->ingredient->name ?? 'N/A' }}</td>
                                    <td>{{ $ri->quantity }} {{ $ri->unit }}</td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            @else
                <div class="empty-state" style="padding: 30px;">
                    <div>Chưa có nguyên liệu</div>
                </div>
            @endif
        </div>
    </div>

    <!-- Hướng dẫn -->
    @if($recipe->instructions)
        <div class="card" style="margin-top: 24px;">
            <div class="card-header">
                <h2 class="card-title">📝 Hướng dẫn nấu</h2>
            </div>
            <div style="white-space: pre-wrap; line-height: 1.8;">{{ $recipe->instructions }}</div>
        </div>
    @endif
@endsection