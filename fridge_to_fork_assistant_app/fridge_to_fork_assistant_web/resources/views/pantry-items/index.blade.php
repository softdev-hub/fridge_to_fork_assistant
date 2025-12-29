@extends('layouts.admin')

@section('title', 'Quản lý Tủ lạnh')
@section('page-title', 'Tủ lạnh')
@section('page-subtitle', 'Quản lý các items trong tủ lạnh của người dùng')

@section('content')
    <!-- Stats -->
    <div class="stats-grid" style="margin-bottom: 24px;">
        <div class="stat-card">
            <div class="stat-icon items">🧊</div>
            <div class="stat-value">{{ number_format($stats['total']) }}</div>
            <div class="stat-label">Tổng items</div>
        </div>
        <div class="stat-card">
            <div class="stat-icon warning">⚠️</div>
            <div class="stat-value">{{ number_format($stats['expiring_soon']) }}</div>
            <div class="stat-label">Sắp hết hạn</div>
        </div>
        <div class="stat-card">
            <div class="stat-icon expired">❌</div>
            <div class="stat-value">{{ number_format($stats['expired']) }}</div>
            <div class="stat-label">Đã hết hạn</div>
        </div>
    </div>

    <!-- Filters -->
    <form method="GET" action="{{ route('pantry-items.index') }}" class="filters">
        <div class="search-box">
            <span class="search-icon">🔍</span>
            <input type="text" name="search" placeholder="Tìm kiếm theo tên nguyên liệu..." value="{{ request('search') }}"
                class="form-input" style="padding-left: 44px;">
        </div>

        <select name="status" class="form-select" style="width: auto; min-width: 180px;">
            <option value="">Tất cả trạng thái</option>
            <option value="expired" {{ request('status') == 'expired' ? 'selected' : '' }}>Đã hết hạn</option>
            <option value="expiring_soon" {{ request('status') == 'expiring_soon' ? 'selected' : '' }}>Sắp hết hạn</option>
            <option value="safe" {{ request('status') == 'safe' ? 'selected' : '' }}>Còn hạn</option>
        </select>

        <select name="user_id" class="form-select" style="width: auto; min-width: 180px;">
            <option value="">Tất cả người dùng</option>
            @foreach($profiles as $profile)
                <option value="{{ $profile->id }}" {{ request('user_id') == $profile->id ? 'selected' : '' }}>
                    {{ $profile->name ?? $profile->id }}
                </option>
            @endforeach
        </select>

        <button type="submit" class="btn btn-secondary">Lọc</button>

        @if(request()->hasAny(['search', 'status', 'user_id']))
            <a href="{{ route('pantry-items.index') }}" class="btn btn-secondary">Xóa bộ lọc</a>
        @endif
    </form>

    <!-- Pantry Items Table -->
    <div class="card">
        <div class="card-header">
            <h2 class="card-title">Danh sách items ({{ $pantryItems->total() }})</h2>
        </div>

        @if($pantryItems->count() > 0)
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Hình ảnh</th>
                            <th>Nguyên liệu</th>
                            <th>Số lượng</th>
                            <th>Người dùng</th>
                            <th>Ngày mua</th>
                            <th>Hạn sử dụng</th>
                            <th>Trạng thái</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($pantryItems as $item)
                            <tr>
                                <td>
                                    @if($item->image_url)
                                        <img src="{{ $item->image_url }}" alt="" class="item-image">
                                    @else
                                        <div class="item-image" style="display: flex; align-items: center; justify-content: center;">
                                            🥗
                                        </div>
                                    @endif
                                </td>
                                <td>
                                    <strong>{{ $item->ingredient->name ?? 'N/A' }}</strong>
                                    @if($item->note)
                                        <div style="color: var(--gray-400); font-size: 12px;">
                                            {{ Str::limit($item->note, 30) }}
                                        </div>
                                    @endif
                                </td>
                                <td>{{ $item->quantity }} {{ $item->unit }}</td>
                                <td>
                                    <a href="{{ route('profiles.show', $item->profile_id) }}"
                                        style="color: var(--primary); text-decoration: none;">
                                        {{ $item->profile->name ?? 'Không rõ' }}
                                    </a>
                                </td>
                                <td>{{ $item->purchase_date?->format('d/m/Y') ?? '-' }}</td>
                                <td>{{ $item->expiry_date?->format('d/m/Y') ?? '-' }}</td>
                                <td>
                                    <span class="status-badge {{ $item->expiry_status_class }}">
                                        {{ $item->expiry_status }}
                                    </span>
                                </td>
                                <td>
                                    <div style="display: flex; gap: 8px;">
                                        <a href="{{ route('pantry-items.show', $item->pantry_item_id) }}"
                                            class="btn btn-secondary btn-sm">
                                            👁️ Xem
                                        </a>
                                        <form action="{{ route('pantry-items.destroy', $item->pantry_item_id) }}" method="POST"
                                            onsubmit="return confirm('Bạn có chắc muốn xóa item này?')">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="btn btn-danger btn-sm">
                                                🗑️
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
                {{ $pantryItems->withQueryString()->links() }}
            </div>
        @else
            <div class="empty-state">
                <div class="empty-state-icon">🧊</div>
                <div class="empty-state-title">Không có items nào</div>
                <p>Không tìm thấy items phù hợp với bộ lọc</p>
            </div>
        @endif
    </div>
@endsection