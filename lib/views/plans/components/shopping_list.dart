import 'package:flutter/material.dart';

class ShoppingItem {
  String name;
  String quantity;
  bool isChecked;

  ShoppingItem(this.name, this.quantity, this.isChecked);
}

class ShoppingListSection extends StatefulWidget {
  const ShoppingListSection({super.key});

  @override
  State<ShoppingListSection> createState() => _ShoppingListSectionState();
}

class _ShoppingListSectionState extends State<ShoppingListSection> {
  List<ShoppingItem> items = [
    ShoppingItem('Hành lá', '2 nhánh', false),
    ShoppingItem('Gừng', '2 miếng', false),
    ShoppingItem('Hành tây', '1 củ', false),
    ShoppingItem('Sữa tươi', '500 ml', true),
    ShoppingItem('Tỏi', '1 củ', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Shopping list items
        ...items.map((item) => _buildShoppingItem(item)),

        const SizedBox(height: 16),

        // Action buttons
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildShoppingItem(ShoppingItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
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
                borderRadius: BorderRadius.circular(4),
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
                    color: item.isChecked
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // Delete icon
          const Icon(Icons.delete_outline, size: 20, color: Color(0xFFD1D5DB)),
        ],
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
        Container(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                items.removeWhere((item) => item.isChecked);
              });
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

  void _showAddIngredientDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddIngredientDialog(),
    );
  }
}

class AddIngredientDialog extends StatefulWidget {
  const AddIngredientDialog({Key? key}) : super(key: key);

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
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thêm nguyên liệu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
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
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
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
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedUnit,
                        isExpanded: true,
                        items: ['g', 'ml', 'cái', 'quả']
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
                      backgroundColor: const Color(0xFFF3F4F6),
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
                      // TODO: Add ingredient logic
                      Navigator.pop(context);
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
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
