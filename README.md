# Bếp Trợ Lý – Fridge-to-Fork Assistant

Table of Contents

- [Mô tả dự án](#mô-tả-dự-án)
- [Mục tiêu giai đoạn đầu](#mục-tiêu-giai-đoạn-đầu)
- [Yêu cầu hệ thống](#yêu-cầu-hệ-thống)
- [Hướng dẫn clone và chạy](#hướng-dẫn-clone-và-chạy)
- [Cấu trúc thư mục chính](#cấu-trúc-thư-mục-chính)

## Mô tả dự án

Ứng dụng di động hỗ trợ người dùng quản lý thực phẩm trong tủ lạnh và gợi ý công thức nấu ăn thông minh dựa trên nguyên liệu có sẵn. Mục tiêu của dự án là giảm lãng phí thực phẩm và tối ưu hóa quy trình nấu ăn cho gia đình.

## Mục tiêu giai đoạn đầu

- Xây dựng giao diện cơ bản: Thiết kế và triển khai màn hình chính của ứng dụng, bao gồm màn hình danh sách nguyên liệu trong tủ lạnh, màn hình gợi ý món ăn và màn hình thông tin người dùng.

- Tương tác đơn giản: Cho phép người dùng thêm/bớt nguyên liệu thủ công và xem danh sách nguyên liệu hiện có. Hiển thị danh sách món ăn mẫu mà ứng dụng có thể gợi ý (nội dung tĩnh, chưa kết nối dữ liệu thật).

- Trải nghiệm người dùng (UI/UX): Tập trung vào trải nghiệm mượt mà, dễ sử dụng, đảm bảo bố cục rõ ràng, trực quan.

- Đa nền tảng: Đảm bảo giao diện hoạt động trên cả Android và iOS bằng Flutter, khởi tạo môi trường cơ bản cho giai đoạn phát triển sau.

## Yêu cầu hệ thống

- Flutter SDK: Phiên bản 3.0 trở lên (đã cài đặt Flutter và Dart).

- Dart: Phiên bản đi kèm với Flutter SDK được hỗ trợ.

- Thiết bị: Android (Android 7.0 trở lên) hoặc iOS (iOS 13 trở lên) có thể chạy thử, hoặc dùng trình giả lập tương ứng.

- IDE: Android Studio, IntelliJ IDEA hoặc Visual Studio Code (cài plugin Flutter và Dart để hỗ trợ phát triển).

- Công cụ khác: Git để clone repository và kết nối Internet để tải gói phụ thuộc.

## Hướng dẫn clone và chạy

Mở terminal, chạy lệnh clone project về máy:

```bash
git clone https://github.com/hainv204/fridge_to_fork_assistant.git
```

Di chuyển vào thư mục dự án:

```bash
cd fridge_to_fork_assistant
```

Cài đặt các gói phụ thuộc:

```bash
flutter pub get
```

Kết nối thiết bị (hoặc khởi chạy trình giả lập), sau đó chạy ứng dụng:

```bash
flutter run
```

Ứng dụng sẽ được biên dịch và hiển thị trên thiết bị. Bạn có thể chỉnh sửa code và thử lại các lệnh trên nếu cần.

## Thiết lập Supabase

1. Tạo project trên Supabase và vào **Settings > API** để sao chép **Project URL** và **anon key**.
2. Từ thư mục gốc, nhân bản file mẫu (Windows PowerShell dùng `Copy-Item` hoặc `copy`, các OS khác dùng `cp`):

```powershell
copy .env.example .env
```

3. Dán giá trị thực vào file `.env`. Không commit file này (đã được thêm vào `.gitignore`).
4. Gọi `await initSupabase()` trong `main.dart` trước khi chạy app để đăng ký client Supabase.
5. Sử dụng `supabase` từ `lib/config.dart` để truy vấn/cập nhật dữ liệu.

Nếu cần phối hợp với team, mỗi người tạo `.env` riêng và giữ bí mật các giá trị Supabase.

## Cấu trúc thư mục chính

```
fridge_to_fork_assistant/
├── .dart_tool/
├── .idea/
├── android/
├── ios/
├── lib/
│   ├── config.dart
│   ├── main.dart
│   ├── controllers/
│   │   └── profile_controller.dart
│   ├── models/
│   │   ├── expiry_alert.dart
│   │   ├── favorite_recipe.dart
│   │   ├── ingredient.dart
│   │   ├── meal_plan.dart
│   │   ├── meal_plan_recipe.dart
│   │   ├── pantry_item.dart
│   │   ├── profile.dart
│   │   ├── recipe.dart
│   │   ├── recipe_ingredient.dart
│   │   ├── shopping_list_items.dart
│   │   ├── user.dart
│   │   ├── user_recipe_matches.dart
│   │   └── weekly_shopping_lists.dart
│   ├── routes/
│   │   └── auth_gate.dart
│   ├── utils/
│   │   ├── constants.dart
│   │   └── date_utils.dart
│   └── views/
│       ├── home.dart
│       ├── auth/
│       │   └── login_view.dart
│       ├── common/
│       │   └── bottom_navigation.dart
│       ├── notification/
│       │   └── notification.dart
│       ├── pantry/
│       │   └── pantry_view.dart
│       ├── plans/
│       │   └── plan_view.dart
│       └── recipes/
│           └── recipe_view.dart
├── linux/
├── macos/
├── test/
└── windows/
```
