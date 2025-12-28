import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/pantry_item_controller.dart';
import '../../controllers/ingredient_controller.dart';
import '../../models/pantry_item.dart';
import '../../models/ingredient.dart';
import '../../models/enums.dart';
import '../../services/storage_service.dart';
import '../../utils/date_utils.dart' as app_date_utils;
import 'components/pantry_constants.dart';
import 'components/pantry_header.dart';
import 'components/pantry_placeholder_image.dart';
import 'components/pantry_label.dart';
import 'components/pantry_date_field.dart';
import 'components/pantry_input_styles.dart';

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
  final _storageService = StorageService();
  final _imagePicker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _noteController;

  late UnitEnum _selectedUnit;
  DateTime? _purchaseDate;
  DateTime? _expiryDate;
  bool _isLoading = false;
  File? _newImage; // Ảnh mới được chọn
  String? _currentImageUrl; // URL ảnh hiện tại

  // Error states for inline validation
  String? _purchaseDateError;
  String? _expiryDateError;

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
    _currentImageUrl = widget.item.imageUrl;
  }

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
      initialDate: isPurchaseDate
          ? (_purchaseDate ?? DateTime.now())
          : (_expiryDate ?? DateTime.now()),
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

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _newImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi chọn ảnh: $e')),
        );
      }
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

      // Upload ảnh mới nếu có
      String? newImageUrl = _currentImageUrl;
      if (_newImage != null) {
        newImageUrl = await _storageService.replacePantryImage(
          _newImage!,
          _currentImageUrl,
        );
      }

      // Update pantry item
      final updatedItem = widget.item.copyWith(
        quantity:
            double.tryParse(_quantityController.text) ?? widget.item.quantity,
        unit: _selectedUnit,
        purchaseDate: _purchaseDate,
        expiryDate: _expiryDate,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        imageUrl: newImageUrl,
      );

      await _pantryController.updatePantryItem(updatedItem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu thay đổi!'),
            backgroundColor: PantryConstants.primaryColor,
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
      backgroundColor: isDark
          ? PantryConstants.backgroundDark
          : PantryConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            PantryHeader(
              title: 'Chỉnh sửa Nguyên liệu',
              onBack: () => Navigator.pop(context),
            ),
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

  Widget _buildImageSection(bool isDark) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(PantryConstants.borderRadius),
            child: _newImage != null
                // Hiển thị ảnh mới nếu có
                ? Image.file(
                    _newImage!,
                    width: 128,
                    height: 128,
                    fit: BoxFit.cover,
                  )
                : _currentImageUrl != null
                    // Hiển thị ảnh từ URL nếu có
                    ? Image.network(
                        _currentImageUrl!,
                        width: 128,
                        height: 128,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            PantryPlaceholderImage.medium(),
                      )
                    : PantryPlaceholderImage.medium(),
          ),
          Positioned(
            bottom: -8,
            right: -8,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PantryConstants.primaryColor,
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

  Widget _buildNameField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PantryLabel(text: 'Tên Nguyên liệu'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _nameController,
          style: TextStyle(color: isDark ? Colors.grey[100] : Colors.grey[900]),
          decoration: pantryInputDecoration('Ví dụ: Thịt bò', isDark),
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
        const PantryLabel(text: 'Số lượng'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _quantityController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: isDark ? Colors.grey[100] : Colors.grey[900]),
          decoration: pantryInputDecoration('200', isDark),
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
          decoration: pantryInputDecoration(
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
      color: isDark
          ? PantryConstants.backgroundDark
          : PantryConstants.backgroundColor,
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
                  borderRadius: BorderRadius.circular(
                    PantryConstants.borderRadius,
                  ),
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
                backgroundColor: PantryConstants.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    PantryConstants.borderRadius,
                  ),
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
}
