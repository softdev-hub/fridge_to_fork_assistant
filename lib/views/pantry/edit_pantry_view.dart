import 'dart:ui';
import 'package:flutter/material.dart';
import '../../controllers/pantry_item_controller.dart';
import '../../controllers/ingredient_controller.dart';
import '../../models/pantry_item.dart';
import '../../models/ingredient.dart';
import '../../models/enums.dart';
import '../../utils/date_utils.dart' as app_date_utils;

class EditPantryView extends StatefulWidget {
  final PantryItem item;

  const EditPantryView({super.key, required this.item});

  @override
  State<EditPantryView> createState() => _EditPantryViewState();
}

class _EditPantryViewState extends State<EditPantryView> {
  final _formKey = GlobalKey<FormState>();
  final _pantryController = PantryItemController();
  final _ingredientController = IngredientController();

  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _noteController;

  late UnitEnum _selectedUnit;
  DateTime? _purchaseDate;
  DateTime? _expiryDate;
  bool _isLoading = false;

  // Error states for inline validation
  String? _purchaseDateError;
  String? _expiryDateError;

  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.item.ingredient?.name ?? '',
    );
    // Format quantity to remove .0 for whole numbers
    final qty = widget.item.quantity;
    _quantityController = TextEditingController(
      text: qty == qty.truncateToDouble()
          ? qty.toInt().toString()
          : qty.toString(),
    );
    _noteController = TextEditingController(text: widget.item.note ?? '');
    _selectedUnit = widget.item.unit;
    _purchaseDate = widget.item.purchaseDate;
    _expiryDate = widget.item.expiryDate;
  }

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
      initialDate: isPurchaseDate
          ? (_purchaseDate ?? DateTime.now())
          : (_expiryDate ?? DateTime.now()),
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

  Future<void> _saveChanges() async {
    // Clear previous errors
    setState(() {
      _purchaseDateError = null;
      _expiryDateError = null;
    });

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
      // Update ingredient name if changed
      final originalName = widget.item.ingredient?.name ?? '';
      final newName = _nameController.text.trim();

      if (newName != originalName && widget.item.ingredient != null) {
        final updatedIngredient = Ingredient(
          ingredientId: widget.item.ingredient!.ingredientId,
          name: newName,
          category: widget.item.ingredient!.category,
          unit: widget.item.ingredient!.unit,
        );
        await _ingredientController.updateIngredient(updatedIngredient);
      }

      // Update pantry item
      final updatedItem = widget.item.copyWith(
        quantity:
            double.tryParse(_quantityController.text) ?? widget.item.quantity,
        unit: _selectedUnit,
        purchaseDate: _purchaseDate,
        expiryDate: _expiryDate,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      await _pantryController.updatePantryItem(updatedItem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu thay đổi!'),
            backgroundColor: primaryColor,
          ),
        );
        Navigator.pop(context, true);
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
                    children: [
                      _buildImageSection(isDark),
                      const SizedBox(height: 24),
                      _buildNameField(isDark),
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
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
            _buildFooter(isDark),
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
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.grey[200] : Colors.grey[800],
                ),
              ),
              Expanded(
                child: Text(
                  'Chỉnh sửa Nguyên liệu',
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

  Widget _buildImageSection(bool isDark) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: widget.item.imageUrl != null
                ? Image.network(
                    widget.item.imageUrl!,
                    width: 128,
                    height: 128,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _buildPlaceholderImage(isDark),
                  )
                : _buildPlaceholderImage(isDark),
          ),
          Positioned(
            bottom: -8,
            right: -8,
            child: GestureDetector(
              onTap: () {
                // TODO: Implement image picker
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(bool isDark) {
    return Container(
      width: 128,
      height: 128,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.restaurant,
        size: 48,
        color: isDark ? Colors.grey[600] : Colors.grey[400],
      ),
    );
  }

  Widget _buildNameField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Tên Nguyên liệu', isDark),
        const SizedBox(height: 6),
        TextFormField(
          controller: _nameController,
          style: TextStyle(color: isDark ? Colors.grey[100] : Colors.grey[900]),
          decoration: _inputDecoration('Ví dụ: Thịt bò', isDark),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập tên nguyên liệu';
            }
            return null;
          },
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
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedUnit = value);
            }
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
          style: TextStyle(color: isDark ? Colors.grey[100] : Colors.grey[900]),
          decoration: _inputDecoration('200', isDark),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập số lượng';
            }
            if (double.tryParse(value) == null) {
              return 'Số lượng không hợp lệ';
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
          decoration: _inputDecoration(
            'Ví dụ: Thịt bò mềm, dùng cho món xào',
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: isDark ? const Color(0xFF121212) : backgroundColor,
      child: Row(
        children: [
          // Cancel button
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Hủy',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[200] : Colors.grey[800],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Save button
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveChanges,
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
                      'Lưu thay đổi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
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
