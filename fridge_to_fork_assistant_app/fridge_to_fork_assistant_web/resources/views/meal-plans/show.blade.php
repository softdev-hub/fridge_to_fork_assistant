@extends('layouts.admin')

@section('title', 'Chi tiết Lịch ăn')
@section('page-title', 'Chi tiết kế hoạch')
@section('page-subtitle', $mealPlan->planned_date->format('d/m/Y') . ' - ' . $mealPlan->meal_type_display)

@section('header-actions')
    <a href="{{ route('meal-plans.index') }}" class="btn btn-secondary">
        ← Quay lại
    </a>
@endsection

@section('content')
    <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 24px;">
        <!-- Thông tin kế hoạch -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title">📅 Thông tin</h2>
                <span class="status-badge {{ $mealPlan->status_class }}">
                    {{ $mealPlan->status_display }}
                </span>
            </div>

            <div style="display: grid; gap: 16px;">
                <div style="text-align: center; padding: 20px; background: var(--gray-50); border-radius: 12px;">
                    <div style="font-size: 32px; margin-bottom: 8px;">
                        @php
                            $icon = match ($mealPlan->meal_type) {
                                'breakfast' => '🌅',
                                'lunch' => '☀️',
                                'dinner' => '🌙',
                                default => '🍽️'
                            };
                        @endphp
                        {{ $icon }}
                    </div>
                    <div style="font-size: 20px; font-weight: 600;">{{ $mealPlan->meal_type_display }}</div>
                    <div style="color: var(--gray-500); margin-top: 4px;">
                        {{ $mealPlan->planned_date->format('l, d/m/Y') }}
                    </div>
                </div>

                <div>
                    <div style="color: var(--gray-500); font-size: 12px; margin-bottom: 4px;">Người dùng</div>
                    <div style="display: flex; align-items: center; gap: 12px;">
                        @if($mealPlan->profile->avatar_url)
                            <img src="{{ $mealPlan->profile->avatar_url }}" alt=""
                                style="width: 40px; height: 40px; border-radius: 8px; object-fit: cover;">
                        @else
                            <div class="avatar">
                                {{ substr($mealPlan->profile->name ?? 'U', 0, 1) }}
                            </div>
                        @endif
                        <a href="{{ route('profiles.show', $mealPlan->profile_id) }}"
                            style="color: var(--primary); text-decoration: none; font-weight: 600;">
                            {{ $mealPlan->profile->name ?? 'Không rõ' }}
                        </a>
                    </div>
                </div>

                <div>
                    <div style="color: var(--gray-500); font-size: 12px; margin-bottom: 4px;">Ngày tạo</div>
                    <div>{{ $mealPlan->created_at->format('d/m/Y H:i') }}</div>
                </div>
            </div>
        </div>

        <!-- Công thức trong kế hoạch -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title">📖 Công thức ({{ $mealPlan->recipes->count() }})</h2>
            </div>

            @if($mealPlan->recipes->count() > 0)
                <div style="display: grid; gap: 16px;">
                    @foreach($mealPlan->recipes as $recipe)
                        <div style="display: flex; gap: 16px; padding: 16px; background: var(--gray-50); border-radius: 12px;">
                            @if($recipe->image_url)
                                <img src="{{ $recipe->image_url }}" alt=""
                                    style="width: 80px; height: 80px; border-radius: 8px; object-fit: cover;">
                            @else
                                <div
                                    style="width: 80px; height: 80px; background: var(--gray-200); border-radius: 8px; 
                                                            display: flex; align-items: center; justify-content: center; font-size: 32px;">
                                    🍳
                                </div>
                            @endif
                            <div style="flex: 1;">
                                <div style="font-size: 16px; font-weight: 600; margin-bottom: 4px;">
                                    {{ $recipe->title }}
                                </div>
                                <div style="display: flex; gap: 12px; color: var(--gray-500); font-size: 13px;">
                                    <span>⏱️ {{ $recipe->cooking_time_minutes ?? '?' }} phút</span>
                                    <span>👥 {{ $recipe->pivot->servings ?? $recipe->servings ?? '?' }} phần</span>
                                    <span>📊 {{ $recipe->difficulty_display }}</span>
                                </div>
                                @if($recipe->recipeIngredients->count() > 0)
                                    <div style="margin-top: 8px;">
                                        <span style="font-size: 12px; color: var(--gray-500);">Nguyên liệu:</span>
                                        @foreach($recipe->recipeIngredients->take(5) as $ri)
                                            <span
                                                style="display: inline-block; background: white; 
                                                                             padding: 2px 6px; border-radius: 4px; font-size: 11px; margin: 2px;">
                                                {{ $ri->ingredient->name ?? 'N/A' }}
                                            </span>
                                        @endforeach
                                        @if($recipe->recipeIngredients->count() > 5)
                                            <span style="font-size: 11px; color: var(--gray-400);">
                                                +{{ $recipe->recipeIngredients->count() - 5 }} khác
                                            </span>
                                        @endif
                                    </div>
                                @endif
                            </div>
                            <a href="{{ route('recipes.show', $recipe->recipe_id) }}" class="btn btn-secondary btn-sm">
                                Xem
                            </a>
                        </div>
                    @endforeach
                </div>
            @else
                <div class="empty-state" style="padding: 30px;">
                    <div>Chưa có công thức nào</div>
                </div>
            @endif
        </div>
    </div>
@endsection