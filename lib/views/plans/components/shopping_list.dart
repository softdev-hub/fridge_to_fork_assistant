import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/shopping_list_service.dart';
import '../../../models/enums.dart';
import '../../../models/shopping_list_items.dart';

class ShoppingItem {
  String name;
  String quantity;
  String sources; // Thông tin nguồn gốc
  bool isChecked;

  ShoppingItem(this.name, this.quantity, this.sources, this.isChecked);
}

class _AutoAgg {
  _AutoAgg({required this.ingredientName, required this.unit});

  final String ingredientName;
  final UnitEnum unit;
  double quantity = 0;
  bool allPurchased = true;
  final Set<String> sources = <String>{};
}

class ShoppingListSection extends StatefulWidget {
  const ShoppingListSection({super.key});

  @override
  State<ShoppingListSection> createState() => _ShoppingListSectionState();
}

class _ShoppingListSectionState extends State<ShoppingListSection> {
  List<ShoppingItem> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShoppingList();
  }

  /// Public method để refresh shopping list từ bên ngoài
  void refreshShoppingList() {
    print('🔄 Shopping list refresh requested');
    _loadShoppingList();
  }

  /// Load shopping list từ database
  Future<void> _loadShoppingList() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        if (mounted) {
          setState(() {
            items = [];
            isLoading = false;
          });
        }
        return;
      }

      // Lấy weekly shopping list cho tuần hiện tại
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weeklyList = await ShoppingListService.instance
          .getOrCreateWeeklyList(profileId: userId, weekStart: weekStart);

      // Lấy items trong weekly list (bao gồm auto + manual)
      final response = await Supabase.instance.client
          .from('shopping_list_items')
          .select('*, ingredients(name), recipes(title)')
          .eq('list_id', weeklyList.listId!)
          .order('created_at', ascending: false);

      final dbItems = (response as List)
          .map(
            (json) => ShoppingListItem.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      print('🛒 Total shopping list items: ${dbItems.length}');

      final auto = dbItems
          // Auto-items are ingredient-based (ingredient_id != null).
          .where((i) => i.ingredientId != null)
          .toList();
      final manual = dbItems
          // Manual items are free-form entries (ingredient_id == null).
          .where((i) => i.ingredientId == null)
          .toList();

      // Aggregate auto-items theo ingredientId + unit.
      final Map<String, _AutoAgg> agg = {};
      for (final it in auto) {
        final ingredientName =
            it.ingredient?.name ?? it.sourceName ?? 'Nguyên liệu';
        final key = '${it.ingredientId ?? 0}|${it.unit.toDbValue()}';
        agg.putIfAbsent(
          key,
          () => _AutoAgg(ingredientName: ingredientName, unit: it.unit),
        );
        agg[key]!.quantity += it.quantity;
        agg[key]!.allPurchased = agg[key]!.allPurchased && it.isPurchased;

        final recipeTitle = it.recipe?.title;
        if (recipeTitle != null && recipeTitle.isNotEmpty) {
          agg[key]!.sources.add(recipeTitle);
        }
      }

      final autoItems = agg.values.map((a) {
        final quantity = '${a.quantity}${a.unit.displayName}';
        final source = a.sources.isEmpty
            ? 'Từ công thức'
            : 'Từ công thức: ${a.sources.join(', ')}';
        return ShoppingItem(a.ingredientName, quantity, source, a.allPurchased);
      }).toList();

      final manualItems = manual.map((dbItem) {
        final name = dbItem.sourceName ?? 'Mục thêm thủ công';
        final quantity = '${dbItem.quantity}${dbItem.unit.displayName}';
        final source = dbItem.sourceName ?? 'Thêm thủ công';
        return ShoppingItem(name, quantity, source, dbItem.isPurchased);
      }).toList();

      final convertedItems = [...autoItems, ...manualItems];

      if (mounted) {
        setState(() {
          items = convertedItems;
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading shopping list: $e');
      if (mounted) {
        setState(() {
          items = [];
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Phần danh sách cho phép scroll
        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
                )
              : items.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildShoppingItem(item);
                  },
                ),
        ),

        // Phần nút luôn nằm dưới cùng
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Danh sách mua sắm trống',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Thêm nguyên liệu cần mua vào danh sách',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingItem(ShoppingItem item) {
    final itemIndex = items.indexOf(item);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Tooltip(
        message: 'Ấn giữ để chỉnh sửa',
        child: InkWell(
          onLongPress: () => _showEditItemDialog(item, itemIndex),
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: () {
                  setState(() {
                    item.isChecked = !item.isChecked;
                  });
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: item.isChecked
                        ? const Color(0xFF22C55E)
                        : Colors.transparent,
                    border: Border.all(
                      color: item.isChecked
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFD1D5DB),
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: item.isChecked
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),

              const SizedBox(width: 12),

              // Item content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: item.isChecked
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF111827),
                        decoration: item.isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.quantity,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: item.isChecked
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.sources,
                      style: TextStyle(
                        fontSize: 12,
                        color: item.isChecked
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),

              // Delete icon
              GestureDetector(
                onTap: () => _deleteItem(items.indexOf(item)),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Add ingredient button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          child: ElevatedButton(
            onPressed: () {
              _showAddIngredientDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Thêm nguyên liệu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),

        // Delete selected button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFEE2E2),
              foregroundColor: const Color(0xFFDC2626),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Xóa các mục đã chọn',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditItemDialog(ShoppingItem item, int index) {
    showDialog(
      context: context,
      builder: (context) => EditIngredientDialog(
        item: item,
        onEdit: (name, quantity, unit) {
          setState(() {
            items[index] = ShoppingItem(
              name,
              '$quantity $unit',
              item.sources, // Keep original source
              item.isChecked,
            );
          });
        },
      ),
    );
  }

  void _deleteItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void _showAddIngredientDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddIngredientDialog(
        onAdd: (name, quantity, unit) {
          setState(() {
            items.add(
              ShoppingItem(name, '$quantity $unit', 'Thêm thủ công', false),
            );
          });
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const DeleteConfirmationDialog();
      },
    ).then((confirmed) {
      if (confirmed == true) {
        setState(() {
          items.removeWhere((item) => item.isChecked);
        });
      }
    });
  }
}

class AddIngredientDialog extends StatefulWidget {
  final Function(String name, String quantity, String unit) onAdd;

  const AddIngredientDialog({super.key, required this.onAdd});

  @override
  State<AddIngredientDialog> createState() => _AddIngredientDialogState();
}

class _AddIngredientDialogState extends State<AddIngredientDialog> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  String _selectedUnit = 'g';

  void _incrementQuantity() {
    int currentValue = int.tryParse(_quantityController.text) ?? 1;
    _quantityController.text = (currentValue + 1).toString();
  }

  void _decrementQuantity() {
    int currentValue = int.tryParse(_quantityController.text) ?? 1;
    if (currentValue > 1) {
      _quantityController.text = (currentValue - 1).toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 300,
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Thêm nguyên liệu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tên nguyên liệu
                  const Text(
                    'Tên nguyên liệu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tên nguyên liệu...',
                        hintStyle: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Số lượng và đơn vị
                  const Text(
                    'Số lượng và đơn vị',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Quantity input with increment/decrement buttons
                      Container(
                        width: 100,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            // Quantity input
                            Expanded(
                              child: TextField(
                                controller: _quantityController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 12,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                            // Increment/Decrement buttons
                            Container(
                              width: 20,
                              margin: const EdgeInsets.only(right: 4),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Increment button
                                  InkWell(
                                    onTap: _incrementQuantity,
                                    borderRadius: BorderRadius.circular(4),
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE5E7EB),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.keyboard_arrow_up,
                                        size: 14,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Decrement button
                                  InkWell(
                                    onTap: _decrementQuantity,
                                    borderRadius: BorderRadius.circular(4),
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE5E7EB),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 14,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Unit dropdown
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              dropdownColor: const Color(0xFFF8F9FA),
                              value: _selectedUnit,
                              isExpanded: true,
                              items:
                                  [
                                        'g',
                                        'kg',
                                        'ml',
                                        'l',
                                        'cái',
                                        'quả',
                                        'cũ',
                                        'nánh',
                                        'chai',
                                        'hộp',
                                      ]
                                      .map(
                                        (unit) => DropdownMenuItem<String>(
                                          value: unit,
                                          child: Text(
                                            unit,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF111827),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedUnit = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Bottom buttons
                  Row(
                    children: [
                      // Hủy button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE5E7EB),
                            foregroundColor: const Color(0xFF6B7280),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Hủy',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Thêm button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_nameController.text.isNotEmpty) {
                              widget.onAdd(
                                _nameController.text.trim(),
                                _quantityController.text,
                                _selectedUnit,
                              );
                              Navigator.pop(context);
                            } else {
                              // Show error if name is empty
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Vui lòng nhập tên nguyên liệu',
                                  ),
                                  backgroundColor: Color(0xFFEF4444),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22C55E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Thêm',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Close button positioned at top right
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}

class EditIngredientDialog extends StatefulWidget {
  final ShoppingItem item;
  final Function(String name, String quantity, String unit) onEdit;

  const EditIngredientDialog({
    super.key,
    required this.item,
    required this.onEdit,
  });

  @override
  State<EditIngredientDialog> createState() => _EditIngredientDialogState();
}

class _EditIngredientDialogState extends State<EditIngredientDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late String _selectedUnit;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);

    // Parse quantity and unit from item.quantity (e.g., "2 kg" -> "2" and "kg")
    final parts = widget.item.quantity.split(' ');
    _quantityController = TextEditingController(text: parts.first);
    _selectedUnit = parts.length > 1 ? parts.last : 'g';
  }

  void _incrementQuantity() {
    int currentValue = int.tryParse(_quantityController.text) ?? 1;
    _quantityController.text = (currentValue + 1).toString();
  }

  void _decrementQuantity() {
    int currentValue = int.tryParse(_quantityController.text) ?? 1;
    if (currentValue > 1) {
      _quantityController.text = (currentValue - 1).toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 300,
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Chỉnh sửa nguyên liệu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tên nguyên liệu
                  const Text(
                    'Tên nguyên liệu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tên nguyên liệu...',
                        hintStyle: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Số lượng và đơn vị
                  const Text(
                    'Số lượng và đơn vị',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Quantity input with increment/decrement buttons
                      Container(
                        width: 100,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            // Quantity input
                            Expanded(
                              child: TextField(
                                controller: _quantityController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 12,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                            // Increment/Decrement buttons
                            Container(
                              width: 20,
                              margin: const EdgeInsets.only(right: 4),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Increment button
                                  InkWell(
                                    onTap: _incrementQuantity,
                                    borderRadius: BorderRadius.circular(4),
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE5E7EB),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.keyboard_arrow_up,
                                        size: 14,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Decrement button
                                  InkWell(
                                    onTap: _decrementQuantity,
                                    borderRadius: BorderRadius.circular(4),
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE5E7EB),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 14,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Unit dropdown
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              dropdownColor: const Color(0xFFF8F9FA),
                              value: _selectedUnit,
                              isExpanded: true,
                              items:
                                  [
                                        'g',
                                        'kg',
                                        'ml',
                                        'l',
                                        'cái',
                                        'quả',
                                        'cũ',
                                        'nánh',
                                        'chai',
                                        'hộp',
                                      ]
                                      .map(
                                        (unit) => DropdownMenuItem<String>(
                                          value: unit,
                                          child: Text(
                                            unit,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF111827),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedUnit = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Bottom buttons
                  Row(
                    children: [
                      // Hủy button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE5E7EB),
                            foregroundColor: const Color(0xFF6B7280),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Hủy',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Cập nhật button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_nameController.text.isNotEmpty) {
                              widget.onEdit(
                                _nameController.text.trim(),
                                _quantityController.text,
                                _selectedUnit,
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Vui lòng nhập tên nguyên liệu',
                                  ),
                                  backgroundColor: Color(0xFFEF4444),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Cập nhật',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Close button positioned at top right
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}

class DeleteConfirmationDialog extends StatefulWidget {
  const DeleteConfirmationDialog({super.key});

  @override
  State<DeleteConfirmationDialog> createState() =>
      _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends State<DeleteConfirmationDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 300,
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề
                  const Text(
                    'Xác nhận xoá',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bạn chắc chắn muốn xoá các mục đã chọn khỏi danh sách mua sắm?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bottom buttons
                  Row(
                    children: [
                      // Hủy button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE5E7EB),
                            foregroundColor: const Color(0xFF6B7280),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Hủy',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Xóa button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Xóa',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Close button positioned at top right
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
