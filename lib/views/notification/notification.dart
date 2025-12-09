import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/controllers/expiry_alert_controller.dart';
import 'package:fridge_to_fork_assistant/models/expiry_alert.dart';
import 'package:fridge_to_fork_assistant/views/pantry/detail_pantry.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  static const Color primaryColor = Color(0xFF4CAF50);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ExpiryAlertController _alertController = ExpiryAlertController();

  bool _isLoading = true;
  Map<String, List<ExpiryAlert>> _groupedAlerts = {
    'today': [],
    'yesterday': [],
    'older': [],
  };

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoading = true);

    try {
      // Generate alerts for expiring items first
      await _alertController.generateAlertsForExpiringItems(
        daysBeforeExpiry: 3,
      );

      // Then fetch all alerts grouped by date
      final grouped = await _alertController.getAlertsGroupedByDate();

      if (mounted) {
        setState(() {
          _groupedAlerts = grouped;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải thông báo: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }

  void _navigateToPantryDetail(ExpiryAlert alert) {
    if (alert.pantryItem != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailPantryView(item: alert.pantryItem!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8FAF7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildContent(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    final hasAlerts =
        _groupedAlerts['today']!.isNotEmpty ||
        _groupedAlerts['yesterday']!.isNotEmpty ||
        _groupedAlerts['older']!.isNotEmpty;

    if (!hasAlerts) {
      return _buildEmptyState(isDark);
    }

    return RefreshIndicator(
      onRefresh: _loadAlerts,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_groupedAlerts['today']!.isNotEmpty) ...[
              _buildSection('Hôm nay', _groupedAlerts['today']!, isDark),
              const SizedBox(height: 20),
            ],
            if (_groupedAlerts['yesterday']!.isNotEmpty) ...[
              _buildSection('Hôm qua', _groupedAlerts['yesterday']!, isDark),
              const SizedBox(height: 20),
            ],
            if (_groupedAlerts['older']!.isNotEmpty)
              _buildSection(
                'Cũ hơn',
                _groupedAlerts['older']!,
                isDark,
                isOld: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Không có thông báo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Các thông báo về nguyên liệu sắp hết hạn\nsẽ xuất hiện ở đây',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.grey[100] : Colors.grey[800],
            ),
          ),
          Text(
            'Thông báo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[100] : Colors.grey[800],
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<ExpiryAlert> alerts,
    bool isDark, {
    bool isOld = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey[100] : Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        ...alerts.map(
          (alert) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAlertItem(alert, isDark, isOld: isOld),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertItem(ExpiryAlert alert, bool isDark, {bool isOld = false}) {
    final daysUntilExpiry = alert.daysUntilExpiry;
    final isExpired = alert.isExpired;
    final isToday = alert.isToday;

    // Determine colors based on urgency
    Color iconBgColor;
    Color iconColor;
    IconData icon;

    if (isExpired) {
      iconBgColor = isDark ? const Color(0xFF5C2121) : const Color(0xFFFEE2E2);
      iconColor = Colors.red[500]!;
      icon = Icons.error;
    } else if (isToday || daysUntilExpiry <= 1) {
      iconBgColor = isDark ? const Color(0xFF5C2121) : const Color(0xFFFEE2E2);
      iconColor = Colors.red[500]!;
      icon = Icons.warning;
    } else if (daysUntilExpiry <= 3) {
      iconBgColor = isDark ? const Color(0xFF5C4B21) : const Color(0xFFFEF3C7);
      iconColor = Colors.orange[600]!;
      icon = Icons.warning;
    } else {
      iconBgColor = isDark
          ? NotificationPage.primaryColor.withAlpha(50)
          : NotificationPage.primaryColor.withAlpha(40);
      iconColor = NotificationPage.primaryColor;
      icon = Icons.info;
    }

    // Build message content
    String expiryText;
    if (isExpired) {
      expiryText = 'đã hết hạn ${-daysUntilExpiry} ngày trước!';
    } else if (isToday) {
      expiryText = 'sẽ hết hạn hôm nay!';
    } else if (daysUntilExpiry == 1) {
      expiryText = 'sẽ hết hạn ngày mai!';
    } else {
      expiryText = 'sẽ hết hạn trong $daysUntilExpiry ngày nữa!';
    }

    return _NotificationItem(
      icon: icon,
      iconBgColor: iconBgColor,
      iconColor: iconColor,
      content: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[100] : Colors.grey[800],
          ),
          children: [
            TextSpan(
              text: alert.ingredientName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: ' của bạn '),
            TextSpan(
              text: expiryText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      time: alert.timeAgo,
      actionText: isExpired ? 'Xem chi tiết' : 'Sử dụng ngay',
      onAction: () => _navigateToPantryDetail(alert),
      isDark: isDark,
      isOld: isOld,
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final Widget content;
  final String time;
  final String? actionText;
  final VoidCallback? onAction;
  final bool isDark;
  final bool isOld;

  const _NotificationItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.content,
    required this.time,
    this.actionText,
    this.onAction,
    required this.isDark,
    this.isOld = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isOld ? 0.7 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  content,
                  const SizedBox(height: 6),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                    ),
                  ),
                  if (actionText != null) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: onAction,
                      child: Text(
                        actionText!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: NotificationPage.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
