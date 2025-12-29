@extends('layouts.admin')

@section('title', 'Chi tiết Item')
@section('page-title', $pantryItem->ingredient->name ?? 'Chi tiết Item')
@section('page-subtitle', 'Thông tin chi tiết của item trong tủ lạnh')

@section('header-actions')
    <a href="{{ route('pantry-items.index') }}" class="btn btn-secondary">
        ← Quay lại
    </a>
@endsection

@section('content')
    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
        <!-- Thông tin item -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title">📦 Thông tin Item</h2>
                <span class="status-badge {{ $pantryItem->expiry_status_class }}">
                    {{ $pantryItem->expiry_status }}
                </span>
            </div>

            @if($pantryItem->image_url)
                <div style="margin-bottom: 20px;">
                    <img src="{{ $pantryItem->image_url }}" alt=""
                        style="width: 100%; max-height: 300px; object-fit: cover; border-radius: 12px;">
                </div>
            @endif

            <div style="display: grid; gap: 16px;">
                <div>
                    <div style="color: var(--gray-500); font-size: 12px; margin-bottom: 4px;">Nguyên liệu</div>
                    <div style="font-size: 18px; font-weight: 600;">{{ $pantryItem->ingredient->name ?? 'N/A' }}</div>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                    <div>
                        <div style="color: var(--gray-500); font-size: 12px; margin-bottom: 4px;">Số lượng</div>
                        <div style="font-weight: 600;">{{ $pantryItem->quantity }} {{ $pantryItem->unit }}</div>
                    </div>
                    <div>
                        <div style="color: var(--gray-500); font-size: 12px; margin-bottom: 4px;">Loại</div>
                        <div style="font-weight: 600;">{{ $pantryItem->ingredient->category_display ?? '-' }}</div>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                    <div>
                        <div style="color: var(--gray-500); font-size: 12px; margin-bottom: 4px;">Ngày mua</div>
                        <div style="font-weight: 600;">{{ $pantryItem->purchase_date?->format('d/m/Y') ?? '-' }}</div>
                    </div>
                    <div>
                        <div style="color: var(--gray-500); font-size: 12px; margin-bottom: 4px;">Hạn sử dụng</div>
                        <div style="font-weight: 600;">{{ $pantryItem->expiry_date?->format('d/m/Y') ?? '-' }}</div>
                    </div>
                </div>

                @if($pantryItem->note)
                    <div>
                        <div style="color: var(--gray-500); font-size: 12px; margin-bottom: 4px;">Ghi chú</div>
                        <div style="background: var(--gray-50); padding: 12px; border-radius: 8px;">
                            {{ $pantryItem->note }}
                        </div>
                    </div>
                @endif

                <div
                    style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; padding-top: 16px; border-top: 1px solid var(--gray-100);">
                    <div>
                        <div style="color: var(--gray-500); font-size: 12px; margin-bottom: 4px;">Ngày tạo</div>
                        <div style="font-size: 14px;">{{ $pantryItem->created_at?->format('d/m/Y H:i') }}</div>
                    </div>
                    <div>
                        <div style="color: var(--gray-500); font-size: 12px; margin-bottom: 4px;">Cập nhật</div>
                        <div style="font-size: 14px;">{{ $pantryItem->updated_at?->format('d/m/Y H:i') }}</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Thông tin người dùng -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title">👤 Người dùng</h2>
            </div>

            <div style="display: flex; align-items: center; gap: 16px; margin-bottom: 20px;">
                @if($pantryItem->profile->avatar_url)
                    <img src="{{ $pantryItem->profile->avatar_url }}" alt=""
                        style="width: 64px; height: 64px; border-radius: 12px; object-fit: cover;">
                @else
                    <div class="avatar" style="width: 64px; height: 64px; font-size: 24px;">
                        {{ substr($pantryItem->profile->name ?? 'U', 0, 1) }}
                    </div>
                @endif
                <div>
                    <div style="font-size: 18px; font-weight: 600;">
                        {{ $pantryItem->profile->name ?? 'Không có tên' }}
                    </div>
                    <div style="color: var(--gray-500); font-size: 14px;">
                        ID: {{ $pantryItem->profile->id }}
                    </div>
                </div>
            </div>

            <a href="{{ route('profiles.show', $pantryItem->profile_id) }}" class="btn btn-secondary" style="width: 100%;">
                Xem hồ sơ người dùng →
            </a>
        </div>
    </div>

    <!-- Actions -->
    <div class="card" style="margin-top: 24px;">
        <div style="display: flex; gap: 12px;">
            <form action="{{ route('pantry-items.destroy', $pantryItem->pantry_item_id) }}" method="POST"
                onsubmit="return confirm('Bạn có chắc muốn xóa item này?')">
                @csrf
                @method('DELETE')
                <button type="submit" class="btn btn-danger">
                    🗑️ Xóa item này
                </button>
            </form>
        </div>
    </div>
@endsection