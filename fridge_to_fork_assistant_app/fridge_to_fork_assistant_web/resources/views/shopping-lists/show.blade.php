@extends('layouts.admin')

@section('title', 'Chi tiết Danh sách mua sắm')
@section('page-title', $shoppingList->title ?? 'Danh sách mua sắm')
@section('page-subtitle', 'Tuần ' . $shoppingList->week_start->format('d/m/Y'))

@section('header-actions')
    <a href="{{ route('shopping-lists.index') }}" class="btn btn-secondary">
        ← Quay lại
    </a>
@endsection

@section('content')
    <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 24px;">
        <!-- Thông tin danh sách -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title">🛒 Thông tin</h2>
            </div>

            <div style="display: grid; gap: 16px;">
                <!-- Progress -->
                <div style="text-align: center; padding: 20px; background: var(--gray-50); border-radius: 12px;">
                    @php
                        $progress = $shoppingList->progress_percent;
                    @endphp
                    <div style="font-size: 48px; font-weight: 700; color: var(--primary);">{{ $progress }}%</div>
                    <div style="color: var(--gray-500); margin-top: 4px;">
                        {{ $shoppingList->purchased_items }} / {{ $shoppingList->total_items }} đã mua
                    </div>
                    <div
                        style="margin-top: 12px; height: 8px; background: var(--gray-200); border-radius: 4px; overflow: hidden;">
                        <div style="width: {{ $progress }}%; height: 100%; 
                                        background: {{ $progress == 100 ? 'var(--success)' : 'var(--primary)' }};"></div>
                    </div>
                </div>

                <div>
                    <div style="color: var(--gray-500); font-size: 12px; margin-bottom: 4px;">Người dùng</div>
                    <div style="display: flex; align-items: center; gap: 12px;">
                        @if($shoppingList->profile->avatar_url)
                            <img src="{{ $shoppingList->profile->avatar_url }}" alt=""
                                style="width: 40px; height: 40px; border-radius: 8px; object-fit: cover;">
                        @else
                            <div class="avatar">
                                {{ substr($shoppingList->profile->name ?? 'U', 0, 1) }}
                            </div>
                        @endif
                        <a href="{{ route('profiles.show', $shoppingList->profile_id) }}"
                            style="color: var(--primary); text-decoration: none; font-weight: 600;">
                            {{ $shoppingList->profile->name ?? 'Không rõ' }}
                        </a>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
                    <div>
                        <div style="color: var(--gray-500); font-size: 12px; margin-bottom: 4px;">Tuần bắt đầu</div>
                        <div style="font-weight: 600;">{{ $shoppingList->week_start->format('d/m/Y') }}</div>
                    </div>
                    <div>
                        <div style="color: var(--gray-500); font-size: 12px; margin-bottom: 4px;">Ngày tạo</div>
                        <div style="font-weight: 600;">{{ $shoppingList->created_at->format('d/m/Y') }}</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Danh sách items -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title">📝 Danh sách ({{ $shoppingList->items->count() }} items)</h2>
            </div>

            @if($shoppingList->items->count() > 0)
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Trạng thái</th>
                                <th>Nguyên liệu</th>
                                <th>Số lượng</th>
                                <th>Nguồn</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($shoppingList->items as $item)
                                <tr style="{{ $item->is_purchased ? 'opacity: 0.5;' : '' }}">
                                    <td>
                                        @if($item->is_purchased)
                                            <span style="color: var(--success); font-size: 20px;">✅</span>
                                        @else
                                            <span style="color: var(--gray-300); font-size: 20px;">⬜</span>
                                        @endif
                                    </td>
                                    <td>
                                        <span style="{{ $item->is_purchased ? 'text-decoration: line-through;' : '' }}">
                                            {{ $item->ingredient->name ?? $item->source_name ?? 'N/A' }}
                                        </span>
                                    </td>
                                    <td>{{ $item->quantity }} {{ $item->unit }}</td>
                                    <td>
                                        @if($item->sourceRecipe)
                                            <a href="{{ route('recipes.show', $item->source_recipe_id) }}"
                                                style="color: var(--primary); text-decoration: none; font-size: 12px;">
                                                📖 {{ $item->sourceRecipe->title }}
                                            </a>
                                        @else
                                            <span style="color: var(--gray-400); font-size: 12px;">-</span>
                                        @endif
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            @else
                <div class="empty-state" style="padding: 30px;">
                    <div>Danh sách trống</div>
                </div>
            @endif
        </div>
    </div>
@endsection