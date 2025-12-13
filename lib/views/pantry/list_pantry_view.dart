import 'dart:ui';
import 'package:flutter/material.dart';
import '../../controllers/pantry_item_controller.dart';
import '../../models/pantry_item.dart';
import '../../utils/date_utils.dart' as app_date_utils;
import 'detail_pantry.dart';
import 'components/pantry_constants.dart';
import 'components/pantry_placeholder_image.dart';

class ListPantryView extends StatefulWidget {
  final int ingredientId;
  final String ingredientName;

  const ListPantryView({
    super.key,
    required this.ingredientId,
    required this.ingredientName,
  });

  @override
  State<ListPantryView> createState() => _ListPantryViewState();
}

class _ListPantryViewState extends State<ListPantryView> {
  final _controller = PantryItemController();
  List<PantryItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final items = await _controller.getPantryItemsByIngredient(
        widget.ingredientId,
      );
      // Sort by expiry date ascending
      app_date_utils.DateUtils.sortByDate(items, (item) => item.expiryDate);
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  Future<void> _deleteAllItems() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            PantryConstants.borderRadiusLarge,
          ),
        ),
        title: const Text(
          'Xác nhận Xóa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn xóa tất cả nguyên liệu này?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[200],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Xóa tất cả',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        for (final item in _items) {
          if (item.pantryItemId != null) {
            await _controller.deletePantryItem(item.pantryItemId!);
          }
        }
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
        }
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
            _buildHeader(isDark),
            Expanded(child: _buildContent(isDark)),
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
          color:
              (isDark
                      ? PantryConstants.backgroundDark
                      : PantryConstants.backgroundColor)
                  .withAlpha(204),
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
                  widget.ingredientName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey[100] : Colors.grey[900],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: PantryConstants.primaryColor),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không có nguyên liệu',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      itemBuilder: (context, index) => _buildItemCard(_items[index], isDark),
    );
  }

  Widget _buildItemCard(PantryItem item, bool isDark) {
    final daysLeft = item.daysUntilExpiry;
    final expiryColor = PantryConstants.getExpiryColor(daysLeft);
    final expiryText = PantryConstants.getExpiryText(daysLeft);

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailPantryView(item: item)),
        );
        if (result == true) {
          _loadData();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(
            PantryConstants.borderRadiusLarge,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(PantryConstants.borderRadius),
              child: item.imageUrl != null
                  ? Image.network(
                      item.imageUrl!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const PantryPlaceholderImage(size: 64),
                    )
                  : const PantryPlaceholderImage(size: 64),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quantity
                  _buildDetailRow(
                    icon: Icons.inventory_2,
                    iconBgColor: Colors.blue[50]!,
                    iconBgColorDark: Colors.blue[900]!.withAlpha(40),
                    iconColor: Colors.blue[400]!,
                    iconColorDark: Colors.blue[300]!,
                    label: 'Số lượng',
                    value:
                        '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 1)} ${item.unit.displayName}',
                    valueColor: isDark ? Colors.white : Colors.grey[900]!,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  // Expiry
                  _buildDetailRow(
                    icon: Icons.access_time,
                    iconBgColor: expiryColor.withAlpha(26),
                    iconBgColorDark: expiryColor.withAlpha(40),
                    iconColor: expiryColor,
                    iconColorDark: expiryColor,
                    label: 'Hạn sử dụng',
                    value: expiryText ?? 'Chưa có',
                    valueColor: expiryColor,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconBgColor,
    required Color iconBgColorDark,
    required Color iconColor,
    required Color iconColorDark,
    required String label,
    required String value,
    required Color valueColor,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDark ? iconBgColorDark : iconBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isDark ? iconColorDark : iconColor,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ],
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
    );
  }
}
