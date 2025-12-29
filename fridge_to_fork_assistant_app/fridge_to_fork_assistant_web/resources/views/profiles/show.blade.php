@extends('layouts.admin')

@section('title', 'Chi tiết Người dùng')
@section('page-title', $profile->name ?? 'Người dùng')
@section('page-subtitle', 'Thông tin chi tiết và tủ lạnh của người dùng')

@section('header-actions')
    <a href="{{ route('profiles.index') }}" class="btn btn-secondary">
        ← Quay lại
    </a>
@endsection

@section('content')
    <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 24px;">
        <!-- Thông tin người dùng -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title">👤 Thông tin</h2>
            </div>

            <div style="text-align: center; margin-bottom: 24px;">
                @if($profile->avatar_url)
                    <img src="{{ $profile->avatar_url }}" alt=""
                        style="width: 100px; height: 100px; border-radius: 50%; object-fit: cover; margin-bottom: 16px;">
                @else
                    <div class="avatar" style="width: 100px; height: 100px; font-size: 36px; margin: 0 auto 16px;">
                        {{ substr($profile->name ?? 'U', 0, 1) }}
                    </div>
                @endif
                <div style="font-size: 20px; font-weight: 600;">{{ $profile->name ?? 'Chưa đặt tên' }}</div>
            </div>

            <div style="display: grid; gap: 16px;">
                <div>
                    <div style="color: var(--gray-500); font-size: 12px; margin-bottom: 4px;">User ID</div>
                    <div
                        style="font-size: 12px; word-break: break-all; background: var(--gray-50); padding: 8px; border-radius: 6px;">
                        {{ $profile->id }}
                    </div>
                </div>
                <div>
                    <div style="color: var(--gray-500); font-size: 12px; margin-bottom: 4px;">Ngày tham gia</div>
                    <div style="font-weight: 600;">{{ $profile->created_at?->format('d/m/Y H:i') ?? '-' }}</div>
                </div>
            </div>

            <!-- Stats -->
            <div
                style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 12px; margin-top: 24px; padding-top: 24px; border-top: 1px solid var(--gray-100);">
                <div style="text-align: center; padding: 12px; background: var(--gray-50); border-radius: 8px;">
                    <div style="font-size: 24px; font-weight: 700; color: var(--primary);">{{ $stats['total_items'] }}</div>
                    <div style="font-size: 11px; color: var(--gray-500);">Tổng items</div>
                </div>
                <div style="text-align: center; padding: 12px; background: var(--warning-light); border-radius: 8px;">
                    <div style="font-size: 24px; font-weight: 700; color: var(--warning);">
                        {{ $stats['expiring_soon_items'] }}</div>
                    <div style="font-size: 11px; color: var(--gray-500);">Sắp hết hạn</div>
                </div>
                <div style="text-align: center; padding: 12px; background: var(--danger-light); border-radius: 8px;">
                    <div style="font-size: 24px; font-weight: 700; color: var(--danger);">{{ $stats['expired_items'] }}
                    </div>
                    <div style="font-size: 11px; color: var(--gray-500);">Đã hết hạn</div>
                </div>
            </div>
        </div>

        <!-- Pantry Items của người dùng -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title">🧊 Tủ lạnh ({{ $pantryItems->count() }} items)</h2>
            </div>

            @if($pantryItems->count() > 0)
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Nguyên liệu</th>
                                <th>Số lượng</th>
                                <th>Hạn sử dụng</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($pantryItems as $item)
                                <tr>
                                    <td>
                                        <strong>{{ $item->ingredient->name ?? 'N/A' }}</strong>
                                        @if($item->note)
                                            <div style="color: var(--gray-400); font-size: 12px;">
                                                {{ Str::limit($item->note, 25) }}
                                            </div>
                                        @endif
                                    </td>
                                    <td>{{ $item->quantity }} {{ $item->unit }}</td>
                                    <td>{{ $item->expiry_date?->format('d/m/Y') ?? '-' }}</td>
                                    <td>
                                        <span class="status-badge {{ $item->expiry_status_class }}">
                                            {{ $item->expiry_status }}
                                        </span>
                                    </td>
                                    <td>
                                        <a href="{{ route('pantry-items.show', $item->pantry_item_id) }}"
                                            class="btn btn-secondary btn-sm">
                                            👁️
                                        </a>
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            @else
                <div class="empty-state">
                    <div class="empty-state-icon">🧊</div>
                    <div class="empty-state-title">Tủ lạnh trống</div>
                    <p>Người dùng này chưa có items nào trong tủ lạnh</p>
                </div>
            @endif
        </div>
    </div>
@endsection