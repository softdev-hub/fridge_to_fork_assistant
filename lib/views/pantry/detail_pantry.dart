import 'dart:ui';
import 'package:flutter/material.dart';
import '../../controllers/pantry_item_controller.dart';
import '../../models/pantry_item.dart';
import '../../utils/date_utils.dart' as app_date_utils;
import 'edit_pantry_view.dart';

class DetailPantryView extends StatefulWidget {
  final PantryItem item;

  const DetailPantryView({super.key, required this.item});

  @override
  State<DetailPantryView> createState() => _DetailPantryViewState();
}

class _DetailPantryViewState extends State<DetailPantryView> {
  final _controller = PantryItemController();
  late PantryItem _item;
  bool _isDeleting = false;

  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color backgroundColor = Color(0xFFF6F8F6);
  static const Color backgroundDark = Color(0xFF102216);

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Xác nhận Xóa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Bạn có chắc chắn muốn xóa nguyên liệu này không?'),
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
              'Xóa',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && _item.pantryItemId != null) {
      setState(() => _isDeleting = true);
      try {
        await _controller.deletePantryItem(_item.pantryItemId!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa nguyên liệu!'),
              backgroundColor: primaryColor,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isDeleting = false);
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
      backgroundColor: isDark ? backgroundDark : backgroundColor,
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
            slivers: [
              // Image section
              SliverToBoxAdapter(child: _buildImageSection(isDark)),
              // Details section
              SliverToBoxAdapter(child: _buildDetailsSection(isDark)),
              // Bottom padding for footer
              const SliverToBoxAdapter(child: SizedBox(height: 160)),
            ],
          ),
          // Fixed header
          Positioned(top: 0, left: 0, right: 0, child: _buildHeader(isDark)),
          // Fixed footer
          Positioned(bottom: 0, left: 0, right: 0, child: _buildFooter(isDark)),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            bottom: 8,
          ),
          color: (isDark ? backgroundDark : backgroundColor).withAlpha(204),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Chi tiết Nguyên liệu',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.grey[900],
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
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 64,
        left: 16,
        right: 16,
      ),
      child: Container(
        height: 288,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: _item.imageUrl != null
              ? Image.network(
                  _item.imageUrl!,
                  width: double.infinity,
                  height: 288,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholderImage(isDark),
                )
              : _buildPlaceholderImage(isDark),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(bool isDark) {
    return Container(
      width: double.infinity,
      height: 288,
      color: isDark ? Colors.grey[800] : Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Không có ảnh',
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      decoration: BoxDecoration(
        color: isDark ? backgroundDark : backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Text(
            _item.ingredient?.name ?? 'Không xác định',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 24),
          // Details rows
          _buildDetailRow(
            'Thể loại',
            _item.ingredient?.category ?? 'Chưa phân loại',
            isDark,
          ),
          _buildDetailRow(
            'Số lượng',
            '${_item.quantity.toStringAsFixed(_item.quantity.truncateToDouble() == _item.quantity ? 0 : 1)} ${_item.unit.displayName}',
            isDark,
          ),
          _buildDetailRow(
            'Ngày mua',
            app_date_utils.DateUtils.formatDate(_item.purchaseDate).isNotEmpty
                ? app_date_utils.DateUtils.formatDate(_item.purchaseDate)
                : 'Chưa có',
            isDark,
          ),
          _buildDetailRow(
            'Hạn sử dụng',
            app_date_utils.DateUtils.formatDate(_item.expiryDate).isNotEmpty
                ? app_date_utils.DateUtils.formatDate(_item.expiryDate)
                : 'Chưa có',
            isDark,
            isExpiry: true,
          ),
          // Notes
          if (_item.note != null && _item.note!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Ghi chú',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _item.note!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.grey[900],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    bool isDark, {
    bool isExpiry = false,
  }) {
    Color valueColor = isDark ? Colors.white : Colors.grey[900]!;

    if (isExpiry && _item.expiryDate != null) {
      final daysLeft = app_date_utils.DateUtils.daysUntil(_item.expiryDate);
      if (daysLeft != null) {
        if (daysLeft < 0) {
          valueColor = Colors.red[500]!;
        } else if (daysLeft <= 3) {
          valueColor = Colors.orange[500]!;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? backgroundDark : backgroundColor,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Edit button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditPantryView(item: _item),
                  ),
                );
                if (result == true) {
                  Navigator.pop(context, true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Chỉnh sửa Nguyên liệu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Delete button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isDeleting ? null : _deleteItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? Colors.red[900]!.withAlpha(40)
                    : Colors.red[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: _isDeleting
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.red[500],
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Xóa Nguyên liệu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[500],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
