import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/enums.dart';
import '../../models/pantry_item.dart';
import '../../controllers/ingredient_controller.dart';
import '../../controllers/pantry_item_controller.dart';
import '../../utils/date_utils.dart' as app_date_utils;

class AddPantryView extends StatefulWidget {
  const AddPantryView({super.key});

  @override
  State<AddPantryView> createState() => _AddPantryViewState();
}

class _AddPantryViewState extends State<AddPantryView> {
  final _formKey = GlobalKey<FormState>();
  final _ingredientController = IngredientController();
  final _pantryItemController = PantryItemController();

  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();

  IngredientCategoryEnum? _selectedCategory;
  UnitEnum? _selectedUnit;
  DateTime? _purchaseDate;
  DateTime? _expiryDate;
  bool _isLoading = false;

  // Error states for inline validation
  String? _purchaseDateError;
  String? _expiryDateError;

  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isPurchaseDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isPurchaseDate) {
          _purchaseDate = picked;
        } else {
          _expiryDate = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    // Clear previous errors
    setState(() {
      _purchaseDateError = null;
      _expiryDateError = null;
    });

    // Validate form fields
    if (!_formKey.currentState!.validate()) return;

    // Validate dates
    final purchaseDateError = app_date_utils.DateUtils.validatePurchaseDate(
      _purchaseDate,
    );
    final expiryDateError = app_date_utils.DateUtils.validateExpiryDate(
      _expiryDate,
    );
    final dateRangeError = app_date_utils.DateUtils.validateDateRange(
      _purchaseDate,
      _expiryDate,
    );

    if (purchaseDateError != null ||
        expiryDateError != null ||
        dateRangeError != null) {
      setState(() {
        _purchaseDateError = purchaseDateError;
        _expiryDateError = expiryDateError ?? dateRangeError;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final ingredient = await _ingredientController.getOrCreateIngredient(
        _nameController.text.trim(),
        category: _selectedCategory?.toDbValue(),
      );

      if (ingredient.ingredientId == null) {
        throw Exception('Không thể tạo nguyên liệu');
      }

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      final pantryItem = PantryItem(
        profileId: userId,
        ingredientId: ingredient.ingredientId!,
        quantity: double.tryParse(_quantityController.text) ?? 0,
        unit: _selectedUnit!,
        purchaseDate: _purchaseDate,
        expiryDate: _expiryDate,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      await _pantryItemController.createPantryItem(pantryItem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm nguyên liệu vào kho!'),
            backgroundColor: primaryColor,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Nhập thủ công', isDark),
                      const SizedBox(height: 16),
                      // Image + Name row
                      _buildImageAndNameRow(isDark),
                      const SizedBox(height: 16),
                      _buildCategoryDropdown(isDark),
                      const SizedBox(height: 16),
                      _buildUnitDropdown(isDark),
                      const SizedBox(height: 16),
                      _buildQuantityField(isDark),
                      const SizedBox(height: 16),
                      _buildDateField(
                        'Ngày mua',
                        _purchaseDate,
                        () => _selectDate(context, true),
                        isDark,
                        errorText: _purchaseDateError,
                      ),
                      const SizedBox(height: 16),
                      _buildDateField(
                        'Hạn sử dụng',
                        _expiryDate,
                        () => _selectDate(context, false),
                        isDark,
                        errorText: _expiryDateError,
                      ),
                      const SizedBox(height: 16),
                      _buildNoteField(isDark),
                      const SizedBox(height: 32),
                      _buildDivider(isDark),
                      const SizedBox(height: 24),
                      _buildScanButtons(isDark),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
            _buildSubmitButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          color: (isDark ? const Color(0xFF121212) : backgroundColor).withAlpha(
            204,
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.grey[200] : Colors.grey[800],
                ),
              ),
              Expanded(
                child: Text(
                  'Thêm Nguyên liệu mới',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey[100] : Colors.grey[900],
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.grey[200] : Colors.grey[800],
      ),
    );
  }

  Widget _buildImageAndNameRow(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image upload box
        GestureDetector(
          onTap: () {
            // TODO: Implement image picker
          },
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: CustomPaint(
              painter: DashedBorderPainter(
                color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ảnh',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Name field
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Tên nguyên liệu', isDark),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                style: TextStyle(
                  color: isDark ? Colors.grey[100] : Colors.grey[900],
                ),
                decoration: _inputDecoration('Nhập tên nguyên liệu', isDark),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên nguyên liệu';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Thể loại', isDark),
        const SizedBox(height: 6),
        DropdownButtonFormField<IngredientCategoryEnum>(
          value: _selectedCategory,
          dropdownColor: isDark ? Colors.grey[800] : Colors.white,
          style: TextStyle(color: isDark ? Colors.grey[100] : Colors.grey[900]),
          decoration: _inputDecoration('Chọn thể loại', isDark),
          items: IngredientCategoryEnum.values.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category.displayName),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedCategory = value),
        ),
      ],
    );
  }

  Widget _buildUnitDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Đơn vị', isDark),
        const SizedBox(height: 6),
        DropdownButtonFormField<UnitEnum>(
          value: _selectedUnit,
          dropdownColor: isDark ? Colors.grey[800] : Colors.white,
          style: TextStyle(color: isDark ? Colors.grey[100] : Colors.grey[900]),
          decoration: _inputDecoration('Chọn đơn vị', isDark),
          items: UnitEnum.values.map((unit) {
            return DropdownMenuItem(value: unit, child: Text(unit.displayName));
          }).toList(),
          onChanged: (value) => setState(() => _selectedUnit = value),
          validator: (value) {
            if (value == null) {
              return 'Vui lòng chọn đơn vị';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildQuantityField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Số lượng', isDark),
        const SizedBox(height: 6),
        TextFormField(
          controller: _quantityController,
          keyboardType: TextInputType.number,
          enabled: _selectedUnit != null,
          style: TextStyle(color: isDark ? Colors.grey[100] : Colors.grey[900]),
          decoration: _inputDecoration('nhập số lượng', isDark).copyWith(
            fillColor: _selectedUnit == null
                ? (isDark ? Colors.grey[700] : Colors.grey[100])
                : (isDark ? Colors.grey[800] : Colors.white),
          ),
          validator: (value) {
            if (_selectedUnit != null &&
                (value == null || value.trim().isEmpty)) {
              return 'Vui lòng nhập số lượng';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? date,
    VoidCallback onTap,
    bool isDark, {
    String? errorText,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isDark),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError
                    ? Colors.red
                    : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
                      : 'Chọn ngày',
                  style: TextStyle(
                    color: date != null
                        ? (isDark ? Colors.grey[100] : Colors.grey[900])
                        : (isDark ? Colors.grey[500] : Colors.grey[400]),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                ),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildNoteField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Ghi chú', isDark),
        const SizedBox(height: 6),
        TextFormField(
          controller: _noteController,
          maxLines: 3,
          style: TextStyle(color: isDark ? Colors.grey[100] : Colors.grey[900]),
          decoration: _inputDecoration('Nhập ghi chú nếu có', isDark),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: isDark ? Colors.grey[600] : Colors.grey[300]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Hoặc thêm tự động',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[500],
            ),
          ),
        ),
        Expanded(
          child: Divider(color: isDark ? Colors.grey[600] : Colors.grey[300]),
        ),
      ],
    );
  }

  Widget _buildScanButtons(bool isDark) {
    return Column(
      children: [
        _buildScanButton(Icons.qr_code_scanner, 'Quét mã vạch', isDark, () {}),
        const SizedBox(height: 12),
        _buildScanButton(Icons.receipt_long, 'Quét hóa đơn', isDark, () {}),
      ],
    );
  }

  Widget _buildScanButton(
    IconData icon,
    String label,
    bool isDark,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[700] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isDark ? Colors.grey[200] : Colors.grey[800]),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[200] : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: isDark ? const Color(0xFF121212) : backgroundColor,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Thêm vào kho',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.grey[300] : Colors.grey[700],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
      filled: true,
      fillColor: isDark ? Colors.grey[800] : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

// Custom painter for dashed border effect
class DashedBorderPainter extends CustomPainter {
  final Color color;

  DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
