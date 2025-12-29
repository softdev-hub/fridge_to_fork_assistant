@extends('layouts.admin')

@section('title', 'Quản lý Người dùng')
@section('page-title', 'Người dùng')
@section('page-subtitle', 'Quản lý danh sách người dùng trong hệ thống')

@section('content')
    <!-- Profiles Table -->
    <div class="card">
        <div class="card-header">
            <h2 class="card-title">Danh sách người dùng ({{ $profiles->total() }})</h2>
        </div>

        @if($profiles->count() > 0)
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Avatar</th>
                            <th>Tên</th>
                            <th>ID</th>
                            <th>Số items</th>
                            <th>Ngày tham gia</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($profiles as $profile)
                            <tr>
                                <td>
                                    @if($profile->avatar_url)
                                        <img src="{{ $profile->avatar_url }}" alt="" class="avatar">
                                    @else
                                        <div class="avatar">
                                            {{ substr($profile->name ?? 'U', 0, 1) }}
                                        </div>
                                    @endif
                                </td>
                                <td>
                                    <strong>{{ $profile->name ?? 'Chưa đặt tên' }}</strong>
                                </td>
                                <td>
                                    <code style="font-size: 11px; color: var(--gray-500);">
                                                    {{ Str::limit($profile->id, 20) }}
                                                </code>
                                </td>
                                <td>
                                    <span
                                        style="background: var(--primary-light); color: var(--primary-dark); 
                                                             padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600;">
                                        {{ $profile->pantry_items_count }} items
                                    </span>
                                </td>
                                <td>{{ $profile->created_at?->format('d/m/Y') ?? '-' }}</td>
                                <td>
                                    <a href="{{ route('profiles.show', $profile->id) }}" class="btn btn-secondary btn-sm">
                                        👁️ Xem chi tiết
                                    </a>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

            <!-- Pagination -->
            <div class="pagination">
                {{ $profiles->links() }}
            </div>
        @else
            <div class="empty-state">
                <div class="empty-state-icon">👥</div>
                <div class="empty-state-title">Chưa có người dùng nào</div>
                <p>Người dùng sẽ xuất hiện khi họ đăng ký qua ứng dụng</p>
            </div>
        @endif
    </div>
@endsection