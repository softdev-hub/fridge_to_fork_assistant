import 'package:flutter/material.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  Widget _buildItem(BuildContext context, IconData icon, String label, int index) {
    final selected = index == currentIndex;
    final color = selected ? const Color(0xFF4CAF50) : Colors.grey[600];
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _buildItem(context, Icons.home, 'Trang chủ', 0),
            _buildItem(context, Icons.inventory, 'Kho', 1),
            _buildItem(context, Icons.restaurant_menu, 'Công thức', 2),
            _buildItem(context, Icons.event_note, 'Kế hoạch', 3),
          ],
        ),
      ),
    );
  }
}