# 🍳 Fridge to Fork - Admin Panel
## 📋 Giới thiệu

**Fridge to Fork Admin Panel** là trang quản trị dành cho ứng dụng di động Fridge to Fork - một ứng dụng giúp người dùng quản lý thực phẩm trong tủ lạnh, theo dõi hạn sử dụng và gợi ý công thức nấu ăn.

Admin Panel này được xây dựng bằng **Laravel 12** và kết nối với **Supabase PostgreSQL** để quản lý dữ liệu backend của ứng dụng.

## ✨ Tính năng chính

### 📊 Dashboard
- Thống kê tổng quan về người dùng, nguyên liệu, pantry items
- Biểu đồ và metrics quan trọng
- Cảnh báo về sản phẩm sắp hết hạn

### 🥗 Quản lý Nguyên liệu (Ingredients)
- Xem danh sách tất cả nguyên liệu
- Thêm, sửa, xóa nguyên liệu
- Phân loại theo danh mục
- Upload hình ảnh nguyên liệu

### 🧊 Quản lý Pantry Items
- Xem danh sách thực phẩm trong kho của người dùng
- Theo dõi ngày hết hạn
- Xem chi tiết từng sản phẩm

### 👥 Quản lý Người dùng (Profiles)
- Xem danh sách người dùng đăng ký
- Xem thông tin chi tiết profile

## 🗂️ Cấu trúc dự án

```
fridge_to_fork_assistant_web/
├── app/
│   ├── Http/Controllers/
│   │   ├── DashboardController.php    # Xử lý trang Dashboard
│   │   ├── IngredientController.php   # CRUD nguyên liệu
│   │   ├── PantryItemController.php   # Quản lý pantry items
│   │   └── ProfileController.php      # Quản lý người dùng
│   └── Models/
│       ├── ExpiryAlert.php            # Model cảnh báo hết hạn
│       ├── Ingredient.php             # Model nguyên liệu
│       ├── PantryItem.php             # Model pantry item
│       └── Profile.php                # Model người dùng
├── resources/views/
│   ├── layouts/                       # Layout chính
│   ├── dashboard.blade.php            # Trang dashboard
│   ├── ingredients/                   # Views quản lý nguyên liệu
│   ├── pantry-items/                  # Views quản lý pantry
│   └── profiles/                      # Views quản lý người dùng
├── routes/
│   └── web.php                        # Định nghĩa routes
└── ...
```

## 🚀 Cài đặt

### Yêu cầu hệ thống
- PHP >= 8.2
- Composer
- Node.js >= 18
- NPM hoặc Yarn

### Các bước cài đặt

1. **Clone repository**
   ```bash
   git clone https://github.com/softdev-hub/fridge_to_fork_assistant/edit/feature/Web-admin
   cd fridge_to_fork_assistant_web
   ```

2. **Cài đặt dependencies PHP**
   ```bash
   composer install
   ```

3. **Cài đặt dependencies Node.js**
   ```bash
   npm install
   ```

4. **Cấu hình môi trường**
   ```bash
   cp .env.example .env
   # Hoặc sử dụng cấu hình Supabase:
   cp .env.supabase .env
   ```

5. **Cấu hình database**
   
   Chỉnh sửa file `.env` với thông tin kết nối Supabase:
   ```env
   DB_CONNECTION=pgsql
   DB_HOST=db.xxxxxxxxxxxx.supabase.co
   DB_PORT=5432
   DB_DATABASE=postgres
   DB_USERNAME=postgres
   DB_PASSWORD=your_password
   ```

6. **Tạo application key**
   ```bash
   php artisan key:generate
   ```

7. **Build assets**
   ```bash
   npm run build
   ```

## 🏃‍♂️ Chạy ứng dụng

### Development mode
```bash
# Sử dụng script có sẵn (chạy server + queue + vite cùng lúc)
composer dev

# Hoặc chạy riêng lẻ:
php artisan serve
npm run dev
```

Truy cập: [http://localhost:8000](http://localhost:8000)

### Production mode
```bash
npm run build
php artisan serve
```

## 📚 Routes

| Method | URI | Action | Mô tả |
|--------|-----|--------|-------|
| GET | `/` | DashboardController@index | Trang Dashboard |
| GET | `/ingredients` | IngredientController@index | Danh sách nguyên liệu |
| GET | `/ingredients/create` | IngredientController@create | Form thêm nguyên liệu |
| POST | `/ingredients` | IngredientController@store | Lưu nguyên liệu mới |
| GET | `/ingredients/{id}` | IngredientController@show | Chi tiết nguyên liệu |
| GET | `/ingredients/{id}/edit` | IngredientController@edit | Form sửa nguyên liệu |
| PUT | `/ingredients/{id}` | IngredientController@update | Cập nhật nguyên liệu |
| DELETE | `/ingredients/{id}` | IngredientController@destroy | Xóa nguyên liệu |
| GET | `/pantry-items` | PantryItemController@index | Danh sách pantry items |
| GET | `/pantry-items/{id}` | PantryItemController@show | Chi tiết pantry item |
| DELETE | `/pantry-items/{id}` | PantryItemController@destroy | Xóa pantry item |
| GET | `/profiles` | ProfileController@index | Danh sách người dùng |
| GET | `/profiles/{id}` | ProfileController@show | Chi tiết người dùng |

## 🧪 Testing

```bash
# Chạy tất cả tests
php artisan test

# Hoặc sử dụng Pest
./vendor/bin/pest
```

## 🛠️ Công nghệ sử dụng

- **Backend:** Laravel 12.x
- **Database:** PostgreSQL (Supabase)
- **Frontend:** Blade Templates, Vite
- **Testing:** Pest PHP

## 📝 License

Dự án này được phát triển cho mục đích học tập.

---
