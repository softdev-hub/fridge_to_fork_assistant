@extends('layouts.admin')

@section('title', 'Quản lý Lịch ăn')
@section('page-title', 'Lịch ăn')
@section('page-subtitle', 'Quản lý kế hoạch bữa ăn của người dùng')

@section('content')
    <!-- Stats -->
    <div class="stats-grid" style="margin-bottom: 24px;">
        <div class="stat-card">
            <div class="stat-icon items">📅</div>
            <div class="stat-value">{{ number_format($stats['total']) }}</div>
            <div class="stat-label">Tổng kế hoạch</div>
        </div>
        <div class="stat-card">
            <div class="stat-icon warning">⏳</div>
            <div class="stat-value">{{ number_format($stats['planned']) }}</div>
            <div class="stat-label">Đã lên kế hoạch</div>
        </div>
        <div class="stat-card">
            <div class="stat-icon users">✅</div>
            <div class="stat-value">{{ number_format($stats['done']) }}</div>
            <div class="stat-label">Hoàn thành</div>
        </div>
        <div class="stat-card">
            <div class="stat-icon expired">⏭️</div>
            <div class="stat-value">{{ number_format($stats['skipped']) }}</div>
            <div class="stat-label">Bỏ qua</div>
        </div>
    </div>

    <!-- Filters -->
    <form method="GET" action="{{ route('meal-plans.index') }}" class="filters">
        <select name="user_id" class="form-select" style="width: auto; min-width: 180px;">
            <option value="">Tất cả người dùng</option>
            @foreach($profiles as $profile)
                <option value="{{ $profile->id }}" {{ request('user_id') == $profile->id ? 'selected' : '' }}>
                    {{ $profile->name ?? $profile->id }}
                </option>
            @endforeach
        </select>

        <select name="status" class="form-select" style="width: auto; min-width: 150px;">
            <option value="">Tất cả trạng thái</option>
            <option value="planned" {{ request('status') == 'planned' ? 'selected' : '' }}>Đã lên kế hoạch</option>
            <option value="done" {{ request('status') == 'done' ? 'selected' : '' }}>Hoàn thành</option>
            <option value="skipped" {{ request('status') == 'skipped' ? 'selected' : '' }}>Bỏ qua</option>
        </select>

        <select name="meal_type" class="form-select" style="width: auto; min-width: 150px;">
            <option value="">Tất cả bữa</option>
            <option value="breakfast" {{ request('meal_type') == 'breakfast' ? 'selected' : '' }}>Bữa sáng</option>
            <option value="lunch" {{ request('meal_type') == 'lunch' ? 'selected' : '' }}>Bữa trưa</option>
            <option value="dinner" {{ request('meal_type') == 'dinner' ? 'selected' : '' }}>Bữa tối</option>
        </select>

        <input type="date" name="date_from" class="form-input" value="{{ request('date_from') }}" style="width: auto;"
            placeholder="Từ ngày">
        <input type="date" name="date_to" class="form-input" value="{{ request('date_to') }}" style="width: auto;"
            placeholder="Đến ngày">

        <button type="submit" class="btn btn-secondary">Lọc</button>

        @if(request()->hasAny(['user_id', 'status', 'meal_type', 'date_from', 'date_to']))
            <a href="{{ route('meal-plans.index') }}" class="btn btn-secondary">Xóa bộ lọc</a>
        @endif
    </form>

    <!-- Meal Plans Table -->
    <div class="card">
        <div class="card-header">
            <h2 class="card-title">Danh sách kế hoạch ({{ $mealPlans->total() }})</h2>
        </div>

        @if($mealPlans->count() > 0)
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Ngày</th>
                            <th>Bữa</th>
                            <th>Người dùng</th>
                            <th>Công thức</th>
                            <th>Trạng thái</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($mealPlans as $plan)
                            <tr>
                                <td>
                                    <strong>{{ $plan->planned_date->format('d/m/Y') }}</strong>
                                    <div style="color: var(--gray-400); font-size: 12px;">
                                        {{ $plan->planned_date->translatedFormat('l') }}
                                    </div>
                                </td>
                                <td>
                                    @php
                                        $mealIcon = match ($plan->meal_type) {
                                            'breakfast' => '🌅',
                                            'lunch' => '☀️',
                                            'dinner' => '🌙',
                                            default => '🍽️'
                                        };
                                    @endphp
                                    {{ $mealIcon }} {{ $plan->meal_type_display }}
                                </td>
                                <td>
                                    <a href="{{ route('profiles.show', $plan->profile_id) }}"
                                        style="color: var(--primary); text-decoration: none;">
                                        {{ $plan->profile->name ?? 'Không rõ' }}
                                    </a>
                                </td>
                                <td>
                                    @if($plan->recipes->count() > 0)
                                        @foreach($plan->recipes as $recipe)
                                            <span
                                                style="display: inline-block; background: var(--gray-100); 
                                                                             padding: 2px 8px; border-radius: 4px; font-size: 12px; margin: 2px;">
                                                {{ $recipe->title }}
                                            </span>
                                        @endforeach
                                    @else
                                        <span style="color: var(--gray-400);">Chưa có</span>
                                    @endif
                                </td>
                                <td>
                                    <span class="status-badge {{ $plan->status_class }}">
                                        {{ $plan->status_display }}
                                    </span>
                                </td>
                                <td>
                                    <div style="display: flex; gap: 8px;">
                                        <a href="{{ route('meal-plans.show', $plan->meal_plan_id) }}"
                                            class="btn btn-secondary btn-sm">👁️</a>
                                        <form action="{{ route('meal-plans.destroy', $plan->meal_plan_id) }}" method="POST"
                                            onsubmit="return confirm('Bạn có chắc muốn xóa kế hoạch này?')">
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
                {{ $mealPlans->withQueryString()->links() }}
            </div>
        @else
            <div class="empty-state">
                <div class="empty-state-icon">📅</div>
                <div class="empty-state-title">Chưa có kế hoạch nào</div>
                <p>Kế hoạch bữa ăn sẽ được tạo từ ứng dụng mobile</p>
            </div>
        @endif
    </div>
@endsection