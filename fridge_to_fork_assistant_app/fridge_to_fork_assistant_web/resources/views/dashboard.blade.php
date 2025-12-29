@extends('layouts.admin')

@section('title', 'Dashboard')
@section('page-title', 'Dashboard')
@section('page-subtitle', 'Tổng quan hệ thống')

@section('content')
    <!-- Stats Grid -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon users">👥</div>
            <div class="stat-value">{{ number_format($stats['total_users']) }}</div>
            <div class="stat-label">Người dùng</div>
        </div>

        <div class="stat-card">
            <div class="stat-icon ingredients">🥬</div>
            <div class="stat-value">{{ number_format($stats['total_ingredients']) }}</div>
            <div class="stat-label">Nguyên liệu</div>
        </div>

        <div class="stat-card">
            <div class="stat-icon items">🧊</div>
            <div class="stat-value">{{ number_format($stats['total_pantry_items']) }}</div>
            <div class="stat-label">Items trong tủ lạnh</div>
        </div>

        <div class="stat-card">
            <div class="stat-icon warning">⚠️</div>
            <div class="stat-value">{{ number_format($stats['expiring_soon_items']) }}</div>
            <div class="stat-label">Sắp hết hạn</div>
        </div>

        <div class="stat-card">
            <div class="stat-icon expired">❌</div>
            <div class="stat-value">{{ number_format($stats['expired_items']) }}</div>
            <div class="stat-label">Đã hết hạn</div>
        </div>
    </div>

    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
        <!-- Items sắp hết hạn -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title">⚠️ Sắp hết hạn (7 ngày tới)</h2>
                <a href="{{ route('pantry-items.index', ['status' => 'expiring_soon']) }}" class="btn btn-secondary btn-sm">
                    Xem tất cả
                </a>
            </div>

            @if($expiringSoonItems->count() > 0)
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Nguyên liệu</th>
                                <th>Người dùng</th>
                                <th>Hạn sử dụng</th>
                                <th>Trạng thái</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($expiringSoonItems as $item)
                                <tr>
                                    <td>
                                        <strong>{{ $item->ingredient->name ?? 'N/A' }}</strong>
                                        <div style="color: var(--gray-500); font-size: 12px;">
                                            {{ $item->quantity }} {{ $item->unit }}
                                        </div>
                                    </td>
                                    <td>{{ $item->profile->name ?? 'Không rõ' }}</td>
                                    <td>{{ $item->expiry_date?->format('d/m/Y') }}</td>
                                    <td>
                                        <span class="status-badge {{ $item->expiry_status_class }}">
                                            {{ $item->expiry_status }}
                                        </span>
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            @else
                <div class="empty-state">
                    <div class="empty-state-icon">✅</div>
                    <div class="empty-state-title">Tuyệt vời!</div>
                    <p>Không có item nào sắp hết hạn</p>
                </div>
            @endif
        </div>

        <!-- Items đã hết hạn -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title">❌ Đã hết hạn</h2>
                <a href="{{ route('pantry-items.index', ['status' => 'expired']) }}" class="btn btn-secondary btn-sm">
                    Xem tất cả
                </a>
            </div>

            @if($expiredItems->count() > 0)
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Nguyên liệu</th>
                                <th>Người dùng</th>
                                <th>Hạn sử dụng</th>
                                <th>Trạng thái</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($expiredItems as $item)
                                <tr>
                                    <td>
                                        <strong>{{ $item->ingredient->name ?? 'N/A' }}</strong>
                                        <div style="color: var(--gray-500); font-size: 12px;">
                                            {{ $item->quantity }} {{ $item->unit }}
                                        </div>
                                    </td>
                                    <td>{{ $item->profile->name ?? 'Không rõ' }}</td>
                                    <td>{{ $item->expiry_date?->format('d/m/Y') }}</td>
                                    <td>
                                        <span class="status-badge status-expired">
                                            {{ $item->expiry_status }}
                                        </span>
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            @else
                <div class="empty-state">
                    <div class="empty-state-icon">✅</div>
                    <div class="empty-state-title">Tuyệt vời!</div>
                    <p>Không có item nào hết hạn</p>
                </div>
            @endif
        </div>
    </div>

    <!-- Thống kê theo category -->
    @if(count($categoryStats) > 0)
        <div class="card" style="margin-top: 24px;">
            <div class="card-header">
                <h2 class="card-title">📊 Nguyên liệu theo loại</h2>
            </div>
            <div style="display: flex; gap: 24px; flex-wrap: wrap;">
                @foreach($categoryStats as $category => $count)
                    <div style="text-align: center; padding: 16px; background: var(--gray-50); border-radius: 12px; min-width: 120px;">
                        <div style="font-size: 24px; margin-bottom: 8px;">
                            @switch($category)
                                @case('sữa') 🥛 @break
                                @case('thịt') 🥩 @break
                                @case('rau') 🥬 @break
                                @case('hạt') 🥜 @break
                                @default 📦
                            @endswitch
                        </div>
                        <div style="font-size: 24px; font-weight: 700; color: var(--gray-900);">{{ $count }}</div>
                        <div style="color: var(--gray-500); font-size: 14px;">{{ ucfirst($category ?? 'Khác') }}</div>
                    </div>
                @endforeach
            </div>
        </div>
    @endif
@endsection
