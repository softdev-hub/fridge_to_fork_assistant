<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Admin Panel') - Fridge to Fork</title>

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <style>
        :root {
            --primary: #10b981;
            --primary-dark: #059669;
            --primary-light: #d1fae5;
            --secondary: #3b82f6;
            --danger: #ef4444;
            --danger-light: #fee2e2;
            --warning: #f59e0b;
            --warning-light: #fef3c7;
            --success: #22c55e;
            --success-light: #dcfce7;
            --gray-50: #f9fafb;
            --gray-100: #f3f4f6;
            --gray-200: #e5e7eb;
            --gray-300: #d1d5db;
            --gray-400: #9ca3af;
            --gray-500: #6b7280;
            --gray-600: #4b5563;
            --gray-700: #374151;
            --gray-800: #1f2937;
            --gray-900: #111827;
            --sidebar-width: 260px;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #f0fdf4 0%, #ecfdf5 50%, #f0fdfa 100%);
            min-height: 100vh;
            color: var(--gray-800);
        }

        /* Sidebar */
        .sidebar {
            position: fixed;
            left: 0;
            top: 0;
            bottom: 0;
            width: var(--sidebar-width);
            background: linear-gradient(180deg, var(--gray-900) 0%, var(--gray-800) 100%);
            padding: 0;
            z-index: 1000;
            box-shadow: 4px 0 20px rgba(0, 0, 0, 0.1);
        }

        .sidebar-header {
            padding: 24px 20px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .sidebar-logo {
            width: 42px;
            height: 42px;
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
        }

        .sidebar-title {
            color: white;
            font-size: 18px;
            font-weight: 600;
        }

        .sidebar-subtitle {
            color: var(--gray-400);
            font-size: 12px;
            margin-top: 2px;
        }

        .sidebar-nav {
            padding: 20px 12px;
        }

        .nav-section {
            margin-bottom: 24px;
        }

        .nav-section-title {
            color: var(--gray-500);
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 0 12px;
            margin-bottom: 8px;
        }

        .nav-link {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 16px;
            color: var(--gray-300);
            text-decoration: none;
            border-radius: 10px;
            margin-bottom: 4px;
            transition: all 0.2s ease;
            font-size: 14px;
            font-weight: 500;
        }

        .nav-link:hover {
            background: rgba(255, 255, 255, 0.08);
            color: white;
        }

        .nav-link.active {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
        }

        .nav-icon {
            width: 20px;
            height: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* Main Content */
        .main-content {
            margin-left: var(--sidebar-width);
            min-height: 100vh;
        }

        .header {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            padding: 16px 32px;
            border-bottom: 1px solid var(--gray-200);
            position: sticky;
            top: 0;
            z-index: 100;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .page-title {
            font-size: 24px;
            font-weight: 700;
            color: var(--gray-900);
        }

        .page-subtitle {
            color: var(--gray-500);
            font-size: 14px;
            margin-top: 2px;
        }

        .content {
            padding: 32px;
        }

        /* Cards */
        .card {
            background: white;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            padding: 24px;
            margin-bottom: 24px;
            border: 1px solid var(--gray-100);
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 16px;
            border-bottom: 1px solid var(--gray-100);
        }

        .card-title {
            font-size: 18px;
            font-weight: 600;
            color: var(--gray-800);
        }

        /* Stats Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            margin-bottom: 32px;
        }

        .stat-card {
            background: white;
            border-radius: 16px;
            padding: 24px;
            border: 1px solid var(--gray-100);
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.1);
        }

        .stat-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            margin-bottom: 16px;
        }

        .stat-icon.users {
            background: var(--primary-light);
        }

        .stat-icon.ingredients {
            background: #dbeafe;
        }

        .stat-icon.items {
            background: #fef3c7;
        }

        .stat-icon.expired {
            background: var(--danger-light);
        }

        .stat-icon.warning {
            background: var(--warning-light);
        }

        .stat-value {
            font-size: 32px;
            font-weight: 700;
            color: var(--gray-900);
            line-height: 1;
        }

        .stat-label {
            color: var(--gray-500);
            font-size: 14px;
            margin-top: 8px;
        }

        /* Tables */
        .table-container {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th {
            text-align: left;
            padding: 12px 16px;
            background: var(--gray-50);
            color: var(--gray-600);
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 1px solid var(--gray-200);
        }

        td {
            padding: 16px;
            border-bottom: 1px solid var(--gray-100);
            font-size: 14px;
        }

        tr:hover {
            background: var(--gray-50);
        }

        /* Status Badges */
        .status-badge {
            display: inline-flex;
            align-items: center;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
        }

        .status-expired {
            background: var(--danger-light);
            color: var(--danger);
        }

        .status-warning {
            background: var(--warning-light);
            color: var(--warning);
        }

        .status-safe {
            background: var(--success-light);
            color: var(--success);
        }

        .status-neutral {
            background: var(--gray-100);
            color: var(--gray-600);
        }

        /* Buttons */
        .btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 500;
            text-decoration: none;
            border: none;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(16, 185, 129, 0.4);
        }

        .btn-secondary {
            background: var(--gray-100);
            color: var(--gray-700);
        }

        .btn-secondary:hover {
            background: var(--gray-200);
        }

        .btn-danger {
            background: var(--danger);
            color: white;
        }

        .btn-danger:hover {
            background: #dc2626;
        }

        .btn-sm {
            padding: 6px 12px;
            font-size: 12px;
        }

        /* Forms */
        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            margin-bottom: 8px;
            font-size: 14px;
            font-weight: 500;
            color: var(--gray-700);
        }

        .form-input,
        .form-select {
            width: 100%;
            padding: 12px 16px;
            border: 1px solid var(--gray-300);
            border-radius: 10px;
            font-size: 14px;
            transition: all 0.2s ease;
            background: white;
        }

        .form-input:focus,
        .form-select:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px var(--primary-light);
        }

        /* Search & Filters */
        .filters {
            display: flex;
            gap: 16px;
            flex-wrap: wrap;
            margin-bottom: 24px;
        }

        .search-box {
            flex: 1;
            min-width: 250px;
            position: relative;
        }

        .search-box input {
            width: 100%;
            padding: 12px 16px 12px 44px;
            border: 1px solid var(--gray-300);
            border-radius: 10px;
            font-size: 14px;
        }

        .search-icon {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--gray-400);
        }

        /* Pagination */
        .pagination {
            display: flex;
            justify-content: center;
            gap: 8px;
            margin-top: 24px;
        }

        .pagination a,
        .pagination span {
            padding: 8px 14px;
            border-radius: 8px;
            font-size: 14px;
            text-decoration: none;
            color: var(--gray-600);
            background: white;
            border: 1px solid var(--gray-200);
        }

        .pagination a:hover {
            background: var(--gray-100);
        }

        .pagination .active span {
            background: var(--primary);
            color: white;
            border-color: var(--primary);
        }

        /* Alerts */
        .alert {
            padding: 16px 20px;
            border-radius: 12px;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .alert-success {
            background: var(--success-light);
            color: #15803d;
            border: 1px solid #86efac;
        }

        .alert-error {
            background: var(--danger-light);
            color: #b91c1c;
            border: 1px solid #fca5a5;
        }

        /* Avatar */
        .avatar {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 14px;
        }

        .avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            border-radius: 10px;
        }

        /* Item Image */
        .item-image {
            width: 48px;
            height: 48px;
            border-radius: 8px;
            object-fit: cover;
            background: var(--gray-100);
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: var(--gray-500);
        }

        .empty-state-icon {
            font-size: 48px;
            margin-bottom: 16px;
        }

        .empty-state-title {
            font-size: 18px;
            font-weight: 600;
            color: var(--gray-700);
            margin-bottom: 8px;
        }

        /* Responsive */
        @media (max-width: 1024px) {
            .sidebar {
                transform: translateX(-100%);
            }

            .main-content {
                margin-left: 0;
            }
        }
    </style>
</head>

<body>
    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <div class="sidebar-logo">🥗</div>
            <div>
                <div class="sidebar-title">Fridge to Fork</div>
                <div class="sidebar-subtitle">Admin Panel</div>
            </div>
        </div>

        <nav class="sidebar-nav">
            <div class="nav-section">
                <div class="nav-section-title">Tổng quan</div>
                <a href="{{ route('dashboard') }}"
                    class="nav-link {{ request()->routeIs('dashboard') ? 'active' : '' }}">
                    <span class="nav-icon">📊</span>
                    Dashboard
                </a>
            </div>

            <div class="nav-section">
                <div class="nav-section-title">Quản lý</div>
                <a href="{{ route('ingredients.index') }}"
                    class="nav-link {{ request()->routeIs('ingredients.*') ? 'active' : '' }}">
                    <span class="nav-icon">🥬</span>
                    Nguyên liệu
                </a>
                <a href="{{ route('pantry-items.index') }}"
                    class="nav-link {{ request()->routeIs('pantry-items.*') ? 'active' : '' }}">
                    <span class="nav-icon">🧊</span>
                    Tủ lạnh
                </a>
                <a href="{{ route('profiles.index') }}"
                    class="nav-link {{ request()->routeIs('profiles.*') ? 'active' : '' }}">
                    <span class="nav-icon">👥</span>
                    Người dùng
                </a>
            </div>
        </nav>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
        <header class="header">
            <div>
                <h1 class="page-title">@yield('page-title', 'Dashboard')</h1>
                <p class="page-subtitle">@yield('page-subtitle', 'Quản lý ứng dụng Fridge to Fork')</p>
            </div>
            <div>
                @yield('header-actions')
            </div>
        </header>

        <div class="content">
            @if(session('success'))
                <div class="alert alert-success">
                    ✅ {{ session('success') }}
                </div>
            @endif

            @if(session('error'))
                <div class="alert alert-error">
                    ❌ {{ session('error') }}
                </div>
            @endif

            @yield('content')
        </div>
    </main>
</body>

</html>