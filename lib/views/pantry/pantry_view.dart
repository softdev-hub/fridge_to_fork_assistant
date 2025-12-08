import 'dart:ui';
import 'package:flutter/material.dart';
import '../../controllers/pantry_item_controller.dart';
import '../../models/pantry_item.dart';
import '../../utils/date_utils.dart' as app_date_utils;
import 'add_pantry_view.dart';

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

  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color backgroundColor = Color(0xFFF8F9FA);

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
      setState(() {
        _allItems = items;
        _expiredItems = items.where((item) => item.isExpired).toList();
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
      backgroundColor: isDark ? const Color(0xFF121212) : backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            _buildSearchBar(isDark),
            _buildTabs(isDark),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: primaryColor,
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
          color: (isDark ? const Color(0xFF121212) : backgroundColor)
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
                borderRadius: BorderRadius.circular(12),
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                // TODO: Implement barcode scanner
              },
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
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
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
        indicatorColor: primaryColor,
        indicatorWeight: 2,
        labelColor: primaryColor,
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
            borderRadius: BorderRadius.circular(16),
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
    final expiryColor = _getExpiryColor(daysLeft);
    final expiryText = _getExpiryText(daysLeft);

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.imageUrl != null
                  ? Image.network(
                      item.imageUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildPlaceholderImage(isDark),
                    )
                  : _buildPlaceholderImage(isDark),
            ),
            const SizedBox(width: 16),
            // Name and quantity
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.ingredient?.name ?? 'Không xác định',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: isDark ? Colors.grey[100] : Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 1)} ${item.unit.displayName}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                    ),
                  ),
                ],
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

  Widget _buildPlaceholderImage(bool isDark) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[700] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.restaurant,
        color: isDark ? Colors.grey[500] : Colors.grey[400],
      ),
    );
  }

  Color _getExpiryColor(int? daysLeft) {
    if (daysLeft == null) return Colors.grey;
    if (daysLeft <= 0) return Colors.red[500]!;
    if (daysLeft <= 2) return Colors.orange[500]!;
    if (daysLeft <= 5) return Colors.orange[400]!;
    return Colors.green[500]!;
  }

  String? _getExpiryText(int? daysLeft) {
    if (daysLeft == null) return null;
    if (daysLeft < 0) return 'Hết hạn ${-daysLeft} ngày';
    if (daysLeft == 0) return 'Hết hạn hôm nay';
    return 'Còn $daysLeft ngày';
  }
}
