import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  static const Color primaryColor = Color(0xFF4CAF50);

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('Hôm nay', [
                      _NotificationItem(
                        icon: Icons.warning,
                        iconBgColor: isDark
                            ? const Color(0xFF5C2121)
                            : const Color(0xFFFEE2E2),
                        iconColor: Colors.red[500]!,
                        content: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.grey[100]
                                  : Colors.grey[800],
                            ),
                            children: const [
                              TextSpan(
                                text: 'Sữa',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: ' của bạn sẽ hết hạn trong '),
                              TextSpan(
                                text: '2 ngày nữa!',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        time: '1 giờ trước',
                        actionText: 'Sử dụng ngay',
                        onAction: () {},
                        isDark: isDark,
                      ),
                      _NotificationItem(
                        icon: Icons.restaurant_menu,
                        iconBgColor: isDark
                            ? primaryColor.withAlpha(50)
                            : primaryColor.withAlpha(40),
                        iconColor: primaryColor,
                        content: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.grey[100]
                                  : Colors.grey[800],
                            ),
                            children: const [
                              TextSpan(text: 'Công thức '),
                              TextSpan(
                                text: 'Bò lúc lắc',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text:
                                    ' đã được thêm vào kế hoạch bữa ăn tối nay.',
                              ),
                            ],
                          ),
                        ),
                        time: '3 giờ trước',
                        actionText: 'Xem kế hoạch',
                        onAction: () {},
                        isDark: isDark,
                      ),
                    ], isDark),
                    const SizedBox(height: 20),
                    _buildSection('Hôm qua', [
                      _NotificationItem(
                        icon: Icons.warning,
                        iconBgColor: isDark
                            ? const Color(0xFF5C2121)
                            : const Color(0xFFFEE2E2),
                        iconColor: Colors.red[500]!,
                        content: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.grey[100]
                                  : Colors.grey[800],
                            ),
                            children: const [
                              TextSpan(
                                text: 'Thịt bò',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: ' sắp hết hạn. Đừng quên sử dụng nhé!',
                              ),
                            ],
                          ),
                        ),
                        time: '1 ngày trước',
                        actionText: 'Tìm công thức',
                        onAction: () {},
                        isDark: isDark,
                      ),
                    ], isDark),
                    const SizedBox(height: 20),
                    _buildSection('Cũ hơn', [
                      _NotificationItem(
                        icon: Icons.shopping_cart,
                        iconBgColor: isDark
                            ? primaryColor.withAlpha(50)
                            : primaryColor.withAlpha(40),
                        iconColor: primaryColor,
                        content: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.grey[100]
                                  : Colors.grey[800],
                            ),
                            children: const [
                              TextSpan(text: 'Bạn có '),
                              TextSpan(
                                text: '3 nguyên liệu',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text:
                                    ' trong danh sách mua sắm. Nhấn để xem chi tiết.',
                              ),
                            ],
                          ),
                        ),
                        time: '3 ngày trước',
                        actionText: 'Xem danh sách',
                        onAction: () {},
                        isDark: isDark,
                      ),
                      _NotificationItem(
                        icon: Icons.tips_and_updates,
                        iconBgColor: isDark
                            ? const Color(0xFF1E3A5F)
                            : const Color(0xFFDBEAFE),
                        iconColor: Colors.blue[500]!,
                        content: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.grey[100]
                                  : Colors.grey[800],
                            ),
                            children: const [
                              TextSpan(text: 'Gợi ý món mới cho bạn: '),
                              TextSpan(
                                text: 'Cá diêu hồng hấp xì dầu',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: '.'),
                            ],
                          ),
                        ),
                        time: '5 ngày trước',
                        isDark: isDark,
                        isOld: true,
                      ),
                    ], isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildSection(String title, List<Widget> items, bool isDark) {
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
        ...items.map(
          (item) =>
              Padding(padding: const EdgeInsets.only(bottom: 12), child: item),
        ),
      ],
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
