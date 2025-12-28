import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();

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
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chọn nguồn ảnh',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey[900],
                ),
              ),
              const SizedBox(height: 24),
              // Camera button
              _buildScanOptionButton(
                icon: Icons.camera_alt,
                label: 'Máy ảnh',
                isDark: isDark,
                onTap: () {
                  Navigator.pop(context);
                  _pickImageAndNavigate(ImageSource.camera);
                },
              ),
              const SizedBox(height: 16),
              // Gallery button
              _buildScanOptionButton(
                icon: Icons.photo_library,
                label: 'Chọn từ thư viện',
                isDark: isDark,
                onTap: () {
                  Navigator.pop(context);
                  _pickImageAndNavigate(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageAndNavigate(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (image != null && mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddPantryView(initialImage: File(image.path)),
          ),
        );
        if (result == true) {
          _loadData();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi chọn ảnh: $e')));
      }
    }
  }

  Widget _buildScanOptionButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[700] : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
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
    final backgroundColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF2F4F6);
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark, backgroundColor),
            _buildSearchAndControls(isDark, surfaceColor),
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
                      child: _buildItemsList(isDark, surfaceColor),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, Color backgroundColor) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          color: backgroundColor.withOpacity(0.8),
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

  Widget _buildSearchAndControls(bool isDark, Color surfaceColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Row(
        children: [
          // Search field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.grey[900],
                ),
                decoration: InputDecoration(
                  hintText: 'Tìm nguyên liệu...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 8),
                    child: Icon(Icons.search, color: Colors.grey[400]),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Barcode scanner button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => _showScanOptionsDialog(isDark),
              icon: Icon(
                Icons.qr_code_scanner,
                color: isDark ? Colors.grey[200] : Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Add button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: PantryConstants.primaryColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: PantryConstants.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
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
    final selectedIndex = _tabController.index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[800]!.withOpacity(0.6)
            : Colors.grey[200]!.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(0);
                setState(() {});
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selectedIndex == 0
                      ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: selectedIndex == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Tất cả (${_allItems.length})',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selectedIndex == 0
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: selectedIndex == 0
                        ? PantryConstants.primaryColor
                        : (isDark ? Colors.grey[400] : Colors.grey[500]),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(1);
                setState(() {});
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selectedIndex == 1
                      ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: selectedIndex == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Đã hết hạn (${_expiredItems.length})',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selectedIndex == 1
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: selectedIndex == 1
                        ? PantryConstants.primaryColor
                        : (isDark ? Colors.grey[400] : Colors.grey[500]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(bool isDark, Color surfaceColor) {
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
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildPantryCard(items[index], isDark, surfaceColor);
      },
    );
  }

  Widget _buildPantryCard(PantryItem item, bool isDark, Color surfaceColor) {
    final daysLeft = item.daysUntilExpiry;

    return GestureDetector(
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    item.imageUrl != null
                        ? Image.network(
                            item.imageUrl!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const PantryPlaceholderImage(size: 80),
                          )
                        : const PantryPlaceholderImage(size: 80),
                    // Overlay ring
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with name and more button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.ingredient?.name ?? 'Không xác định',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            height: 1.2,
                            color: isDark ? Colors.white : Colors.grey[900],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.more_horiz,
                        size: 20,
                        color: isDark ? Colors.grey[600] : Colors.grey[300],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Quantity
                  Text(
                    _getQuantityText(item),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Expiry badge
                  _buildExpiryBadge(daysLeft, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getQuantityText(PantryItem item) {
    final quantity = item.quantity;
    final unitStr = item.unit.displayName;
    // Format quantity: show as integer if whole number
    final quantityStr = quantity == quantity.roundToDouble()
        ? quantity.round().toString()
        : quantity.toString();
    return '$quantityStr $unitStr'.trim();
  }

  Widget _buildExpiryBadge(int? daysLeft, bool isDark) {
    if (daysLeft == null) {
      return const SizedBox.shrink();
    }

    Color bgColor;
    Color textColor;
    IconData icon;
    String text;

    if (daysLeft < 0) {
      // Expired
      bgColor = isDark ? Colors.red[900]!.withOpacity(0.2) : Colors.red[50]!;
      textColor = isDark ? Colors.red[400]! : Colors.red[600]!;
      icon = Icons.warning;
      text = 'Hết hạn ${-daysLeft} ngày';
    } else if (daysLeft == 0) {
      // Expires today
      bgColor = isDark ? Colors.red[900]!.withOpacity(0.2) : Colors.red[50]!;
      textColor = isDark ? Colors.red[400]! : Colors.red[600]!;
      icon = Icons.warning;
      text = 'Hết hạn hôm nay';
    } else if (daysLeft <= 2) {
      // Expires very soon (1-2 days)
      bgColor = isDark ? Colors.red[900]!.withOpacity(0.2) : Colors.red[50]!;
      textColor = isDark ? Colors.red[400]! : Colors.red[600]!;
      icon = Icons.warning;
      text = 'Còn $daysLeft ngày';
    } else if (daysLeft <= 5) {
      // Expires soon (3-5 days)
      bgColor = isDark
          ? Colors.orange[900]!.withOpacity(0.2)
          : Colors.orange[50]!;
      textColor = isDark ? Colors.orange[400]! : Colors.orange[600]!;
      icon = Icons.schedule;
      text = 'Còn $daysLeft ngày';
    } else {
      // Good (5+ days)
      bgColor = isDark
          ? Colors.green[900]!.withOpacity(0.2)
          : Colors.green[50]!;
      textColor = isDark ? Colors.green[400]! : Colors.green[700]!;
      icon = Icons.check_circle;
      text = 'Còn $daysLeft ngày';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
