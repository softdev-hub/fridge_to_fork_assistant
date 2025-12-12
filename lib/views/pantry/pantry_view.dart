import 'dart:ui';
import 'package:flutter/material.dart';
import '../../controllers/pantry_item_controller.dart';
import '../../models/pantry_item.dart';
import '../../utils/date_utils.dart' as app_date_utils;
import 'add_pantry_view.dart';
import 'list_pantry_view.dart';
import 'components/pantry_constants.dart';
import 'components/pantry_placeholder_image.dart';

class PantryView extends StatefulWidget {
  const PantryView({super.key});

  @override
  State<PantryView> createState() => _PantryViewState();
}

class _PantryViewState extends State<PantryView>
    with SingleTickerProviderStateMixin {
  final PantryItemController _controller = PantryItemController();
  final TextEditingController _searchController = TextEditingController();

  late TabController _tabController;
  List<PantryItem> _allItems = [];
  List<PantryItem> _expiredItems = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final items = await _controller.getAllPantryItems();
      // Sort by expiry date ascending (soonest first, null dates at end)
      app_date_utils.DateUtils.sortByDate(items, (item) => item.expiryDate);

      // Group by ingredient name and keep only the one with earliest expiry
      final Map<int, PantryItem> groupedItems = {};
      for (final item in items) {
        final ingredientId = item.ingredientId;
        if (!groupedItems.containsKey(ingredientId)) {
          groupedItems[ingredientId] = item;
        }
        // Already sorted, so first item has earliest expiry
      }
      final uniqueItems = groupedItems.values.toList();

      setState(() {
        // Exclude expired items from "All" tab
        _allItems = uniqueItems.where((item) => !item.isExpired).toList();
        _expiredItems = uniqueItems.where((item) => item.isExpired).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
      }
    }
  }

  void _showScanOptionsDialog(bool isDark) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chọn phương thức quét',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[100] : Colors.grey[900],
                ),
              ),
              const SizedBox(height: 24),
              // Scan barcode button
              _buildScanOptionButton(
                icon: Icons.qr_code_scanner,
                label: 'Quét mã vạch',
                isDark: isDark,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement barcode scanner
                },
              ),
              const SizedBox(height: 16),
              // Scan receipt button
              _buildScanOptionButton(
                icon: Icons.receipt_long,
                label: 'Quét hóa đơn',
                isDark: isDark,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement receipt scanner
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanOptionButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(PantryConstants.borderRadius),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[700] : Colors.grey[100],
          borderRadius: BorderRadius.circular(PantryConstants.borderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isDark ? Colors.grey[100] : Colors.grey[800]),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[100] : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PantryItem> get _filteredItems {
    final items = _tabController.index == 0 ? _allItems : _expiredItems;
    if (_searchQuery.isEmpty) return items;
    return items.where((item) {
      final name = item.ingredient?.name.toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
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
            _buildSearchBar(isDark),
            _buildTabs(isDark),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: PantryConstants.primaryColor,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: PantryConstants.primaryColor,
                      child: _buildItemsList(isDark),
                    ),
            ),
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
                  .withOpacity(0.8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 32),
              Text(
                'Kho Nguyên liệu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[100] : Colors.grey[900],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.more_vert,
                  color: isDark ? Colors.grey[200] : Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Search field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(
                  PantryConstants.borderRadius,
                ),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: TextStyle(
                  color: isDark ? Colors.grey[100] : Colors.grey[900],
                ),
                decoration: InputDecoration(
                  hintText: 'Tìm nguyên liệu...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Barcode scanner button
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[200],
              borderRadius: BorderRadius.circular(PantryConstants.borderRadius),
            ),
            child: IconButton(
              onPressed: () => _showScanOptionsDialog(isDark),
              icon: Icon(
                Icons.qr_code_scanner,
                color: isDark ? Colors.grey[200] : Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Add button
          Container(
            decoration: BoxDecoration(
              color: PantryConstants.primaryColor,
              borderRadius: BorderRadius.circular(PantryConstants.borderRadius),
            ),
            child: IconButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPantryView()),
                );
                if (result == true) {
                  _loadData();
                }
              },
              icon: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (_) => setState(() {}),
        indicatorColor: PantryConstants.primaryColor,
        indicatorWeight: 2,
        labelColor: PantryConstants.primaryColor,
        unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[500],
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        tabs: [
          Tab(text: 'Tất cả (${_allItems.length})'),
          Tab(text: 'Đã hết hạn (${_expiredItems.length})'),
        ],
      ),
    );
  }

  Widget _buildItemsList(bool isDark) {
    final items = _filteredItems;

    if (items.isEmpty) {
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
              _tabController.index == 0
                  ? 'Chưa có nguyên liệu nào'
                  : 'Không có nguyên liệu hết hạn',
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
      itemCount: 1,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(
              PantryConstants.borderRadiusLarge,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: isDark ? Colors.grey[700] : Colors.grey[100],
            ),
            itemBuilder: (context, index) {
              return _buildPantryItem(items[index], isDark);
            },
          ),
        );
      },
    );
  }

  Widget _buildPantryItem(PantryItem item, bool isDark) {
    final daysLeft = item.daysUntilExpiry;
    final expiryColor = PantryConstants.getExpiryColor(daysLeft);
    final expiryText = PantryConstants.getExpiryText(daysLeft);

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListPantryView(
              ingredientId: item.ingredientId,
              ingredientName: item.ingredient?.name ?? 'Nguyên liệu',
            ),
          ),
        );
        if (result == true) {
          _loadData();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(PantryConstants.borderRadius),
              child: item.imageUrl != null
                  ? Image.network(
                      item.imageUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const PantryPlaceholderImage(size: 48),
                    )
                  : const PantryPlaceholderImage(size: 48),
            ),
            const SizedBox(width: 16),
            // Name only (removed quantity)
            Expanded(
              child: Text(
                item.ingredient?.name ?? 'Không xác định',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: isDark ? Colors.grey[100] : Colors.grey[900],
                ),
              ),
            ),
            // Expiry
            if (expiryText != null)
              Text(
                expiryText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: expiryColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
