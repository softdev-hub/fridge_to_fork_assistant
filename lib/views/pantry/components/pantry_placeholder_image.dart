import 'package:flutter/material.dart';

/// Placeholder image cho khi không có ảnh nguyên liệu.
class PantryPlaceholderImage extends StatelessWidget {
  final double size;
  final double? width;
  final double? height;
  final double borderRadius;
  final IconData icon;
  final double iconSize;
  final String? text;

  const PantryPlaceholderImage({
    super.key,
    this.size = 48,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.icon = Icons.restaurant,
    this.iconSize = 24,
    this.text,
  });

  /// Factory constructor cho kích thước nhỏ (48x48)
  factory PantryPlaceholderImage.small() {
    return const PantryPlaceholderImage(size: 48, iconSize: 24);
  }

  /// Factory constructor cho kích thước vừa (128x128)
  factory PantryPlaceholderImage.medium() {
    return const PantryPlaceholderImage(size: 128, iconSize: 48);
  }

  /// Factory constructor cho kích thước lớn (full width, height 288)
  factory PantryPlaceholderImage.large() {
    return const PantryPlaceholderImage(
      width: double.infinity,
      height: 288,
      iconSize: 64,
      text: 'Không có ảnh',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width ?? size,
      height: height ?? size,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          if (text != null) ...[
            const SizedBox(height: 8),
            Text(
              text!,
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
