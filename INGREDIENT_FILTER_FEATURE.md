# Chức năng Navigate từ Notification đến Recipe với Filter

## Tổng quan
Chức năng này cho phép người dùng nhấn vào thông báo về nguyên liệu sắp hết hạn và được chuyển trực tiếp đến trang công thức với bộ lọc đã được áp dụng để hiển thị các món ăn có thể làm từ nguyên liệu đó.

## Các tính năng đã implement

### 1. Mở rộng RecipeFilterOptions
- Thêm field `ingredientLabels` để hỗ trợ filter theo nguyên liệu
- Cập nhật constructor và factory method để xử lý ingredient filters

### 2. Logic filter theo nguyên liệu 
- Thêm method `_normalizeIngredients()` để normalize tên nguyên liệu
- Thêm method `_matchIngredient()` để kiểm tra recipe có chứa nguyên liệu được filter hay không
- Thêm method `_matchIngredientInRecipe()` cho việc filter trực tiếp trên Recipe objects

### 3. Cập nhật UI để hiển thị ingredient filter
- Cập nhật `RecipeMatchingFilterBar` để hiển thị chip cho ingredient filter với icon eco
- Format hiển thị: "Nguyên liệu: [tên nguyên liệu]"

### 4. Navigation từ Notification
- Cập nhật `RecipeMatchingView` để nhận parameter `initialIngredientFilter`
- Khi có parameter này, tự động áp dụng filter theo nguyên liệu
- Cập nhật notification để navigate đến recipe với filter khi nhấn "Sử dụng ngay"

### 5. Utility class cho navigation
- Tạo `NavigationUtils` class với methods:
  - `navigateToRecipesWithIngredient()`: Navigate với ingredient filter
  - `navigateToRecipes()`: Navigate không filter

## Cách sử dụng

### Từ Notification
1. Mở ứng dụng và vào tab Thông báo
2. Nhấn vào button "Sử dụng ngay" của bất kỳ thông báo nguyên liệu nào
3. Sẽ được chuyển đến trang Recipe với filter đã áp dụng cho nguyên liệu đó

### Test button
- Đã thêm một test button "Test: Món từ Cà rốt" trên trang chủ để demo chức năng
- Button này sẽ navigate đến trang recipe với filter "cà rốt"

## Technical Details

### Files đã chỉnh sửa:
1. `lib/controllers/recipe_suggestion_filters.dart` - Thêm logic filter theo ingredient
2. `lib/views/recipes/recipe_matching_view.dart` - Thêm initialIngredientFilter parameter
3. `lib/views/recipes/components/recipe_matching_filter_bar.dart` - Hiển thị ingredient filter
4. `lib/views/recipes/components/recipe_list_screen.dart` - Cập nhật default filter options  
5. `lib/views/notification/notification.dart` - Logic navigate với ingredient filter
6. `lib/views/home_view.dart` - Test button
7. `lib/utils/navigation_utils.dart` - Utility methods

### Filter Logic:
- Sử dụng string matching với lowercase comparison
- Hỗ trợ partial matching (ví dụ: "cà rốt" sẽ match với "Cà rốt baby")
- Filter áp dụng trên cả matched và missing ingredients của recipe

### UI/UX Improvements:
- Ingredient filter chip có màu xanh và icon eco
- Hiển thị label rõ ràng "Nguyên liệu: [tên]"  
- Tích hợp seamlessly với existing filter system

## Testing
- Sử dụng test button trên trang chủ để test nhanh
- Hoặc tạo thông báo thực và test từ notification screen
- Kiểm tra filter hoạt động đúng bằng cách xem các recipe được hiển thị có chứa nguyên liệu được filter hay không