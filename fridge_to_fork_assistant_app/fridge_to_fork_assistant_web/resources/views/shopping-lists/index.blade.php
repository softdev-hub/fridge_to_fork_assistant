@extends('layouts.admin')

@section('title', 'Quản lý Danh sách mua sắm')
@section('page-title', 'Danh sách mua sắm')
@section('page-subtitle', 'Quản lý danh sách mua sắm hàng tuần')

@section('content')
    <!-- Filters -->
    <form method="GET" action="{{ route('shopping-lists.index') }}" class="filters">
        <select name="user_id" class="form-select" style="width: auto; min-width: 180px;">
            <option value="">Tất cả người dùng</option>
            @foreach($profiles as $profile)
                <option value="{{ $profile->id }}" {{ request('user_id') == $profile->id ? 'selected' : '' }}>
                    {{ $profile->name ?? $profile->id }}
                </option>
            @endforeach
        </select>

        <button type="submit" class="btn btn-secondary">Lọc</button>

        @if(request()->hasAny(['user_id']))
            <a href="{{ route('shopping-lists.index') }}" class="btn btn-secondary">Xóa bộ lọc</a>
        @endif
    </form>

    <!-- Shopping Lists Table -->
    <div class="card">
        <div class="card-header">
            <h2 class="card-title">Danh sách ({{ $shoppingLists->total() }})</h2>
        </div>

        @if($shoppingLists->count() > 0)
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tiêu đề</th>
                            <th>Người dùng</th>
                            <th>Tuần bắt đầu</th>
                            <th>Số items</th>
                            <th>Tiến độ</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($shoppingLists as $list)
                            <tr>
                                <td>{{ $list->list_id }}</td>
                                <td>
                                    <strong>{{ $list->title ?? 'Danh sách #' . $list->list_id }}</strong>
                                </td>
                                <td>
                                    <a href="{{ route('profiles.show', $list->profile_id) }}"
                                        style="color: var(--primary); text-decoration: none;">
                                        {{ $list->profile->name ?? 'Không rõ' }}
                                    </a>
                                </td>
                                <td>{{ $list->week_start->format('d/m/Y') }}</td>
                                <td>{{ $list->items_count }} items</td>
                                <td>
                                    @php
                                        $progress = $list->progress_percent;
                                        $progressClass = $progress == 100 ? 'var(--success)' :
                                            ($progress >= 50 ? 'var(--warning)' : 'var(--gray-400)');
                                    @endphp
                                    <div style="display: flex; align-items: center; gap: 8px;">
                                        <div
                                            style="flex: 1; height: 8px; background: var(--gray-200); border-radius: 4px; overflow: hidden;">
                                            <div style="width: {{ $progress }}%; height: 100%; background: {{ $progressClass }};">
                                            </div>
                                        </div>
                                        <span style="font-size: 12px; font-weight: 600;">{{ $progress }}%</span>
                                    </div>
                                </td>
                                <td>
                                    <div style="display: flex; gap: 8px;">
                                        <a href="{{ route('shopping-lists.show', $list->list_id) }}"
                                            class="btn btn-secondary btn-sm">👁️ Xem</a>
                                        <form action="{{ route('shopping-lists.destroy', $list->list_id) }}" method="POST"
                                            onsubmit="return confirm('Bạn có chắc muốn xóa danh sách này?')">
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
                {{ $shoppingLists->withQueryString()->links() }}
            </div>
        @else
            <div class="empty-state">
                <div class="empty-state-icon">🛒</div>
                <div class="empty-state-title">Chưa có danh sách nào</div>
                <p>Danh sách mua sắm sẽ được tạo từ ứng dụng mobile</p>
            </div>
        @endif
    </div>
@endsection