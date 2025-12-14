import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/enums.dart';
import '../../models/pantry_item.dart';
import '../../controllers/ingredient_controller.dart';
import '../../controllers/pantry_item_controller.dart';
import '../../utils/date_utils.dart' as app_date_utils;
import 'components/pantry_constants.dart';
import 'components/pantry_header.dart';
import 'components/pantry_label.dart';
import 'components/pantry_date_field.dart';
import 'components/pantry_input_styles.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isPurchaseDate) async {
    final DateTime? picked = await PantryDateField.showPicker(
      context,
      initialDate: isPurchaseDate ? _purchaseDate : _expiryDate,
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
            backgroundColor: PantryConstants.primaryColor,
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
      backgroundColor: isDark
          ? PantryConstants.backgroundDark
          : PantryConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            PantryHeader(
              title: 'Thêm Nguyên liệu mới',
              onBack: () => Navigator.of(context).pop(),
            ),
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
                      PantryDateField(
                        label: 'Ngày mua',
                        date: _purchaseDate,
                        onTap: () => _selectDate(context, true),
                        errorText: _purchaseDateError,
                      ),
                      const SizedBox(height: 16),
                      PantryDateField(
                        label: 'Hạn sử dụng',
                        date: _expiryDate,
                        onTap: () => _selectDate(context, false),
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
              borderRadius: BorderRadius.circular(PantryConstants.borderRadius),
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
              const PantryLabel(text: 'Tên nguyên liệu'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                style: TextStyle(
                  color: isDark ? Colors.grey[100] : Colors.grey[900],
                ),
                decoration: pantryInputDecoration(
                  'Nhập tên nguyên liệu',
                  isDark,
                ),
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
        const PantryLabel(text: 'Thể loại'),
        const SizedBox(height: 6),
        DropdownButtonFormField<IngredientCategoryEnum>(
          value: _selectedCategory,
          dropdownColor: isDark ? Colors.grey[800] : Colors.white,
          style: TextStyle(color: isDark ? Colors.grey[100] : Colors.grey[900]),
          decoration: pantryInputDecoration('Chọn thể loại', isDark),
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
        const PantryLabel(text: 'Đơn vị'),
        const SizedBox(height: 6),
        DropdownButtonFormField<UnitEnum>(
          value: _selectedUnit,
          dropdownColor: isDark ? Colors.grey[800] : Colors.white,
          style: TextStyle(color: isDark ? Colors.grey[100] : Colors.grey[900]),
          decoration: pantryInputDecoration('Chọn đơn vị', isDark),
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
        const PantryLabel(text: 'Số lượng'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _quantityController,
          keyboardType: TextInputType.number,
          enabled: _selectedUnit != null,
          style: TextStyle(color: isDark ? Colors.grey[100] : Colors.grey[900]),
          decoration: pantryInputDecoration(
            'nhập số lượng',
            isDark,
            enabled: _selectedUnit != null,
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

  Widget _buildNoteField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PantryLabel(text: 'Ghi chú'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _noteController,
          maxLines: 3,
          style: TextStyle(color: isDark ? Colors.grey[100] : Colors.grey[900]),
          decoration: pantryInputDecoration('Nhập ghi chú nếu có', isDark),
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
          borderRadius: BorderRadius.circular(PantryConstants.borderRadius),
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
      color: isDark
          ? PantryConstants.backgroundDark
          : PantryConstants.backgroundColor,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: PantryConstants.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PantryConstants.borderRadius),
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
}

// Custom painter for dashed border effect
class DashedBorderPainter extends CustomPainter {
  final Color color;

  DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
