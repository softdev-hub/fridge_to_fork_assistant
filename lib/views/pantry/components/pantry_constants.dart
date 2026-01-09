import 'package:flutter/material.dart';

/// Constants chung cho các màn hình Pantry.
class PantryConstants {
  PantryConstants._();

  // Colors
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color backgroundDetailDark = Color(0xFF102216);
  static const Color backgroundDetail = Color(0xFFF6F8F6);

  // Border radius
  static const double borderRadius = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  // Expiry colors
  static Color getExpiryColor(int? daysLeft) {
    if (daysLeft == null) return Colors.grey;
    if (daysLeft <= 0) return Colors.red[500]!;
    if (daysLeft <= 2) return Colors.orange[500]!;
    if (daysLeft <= 5) return Colors.orange[400]!;
    return Colors.green[500]!;
  }

  // Expiry text
  static String? getExpiryText(int? daysLeft) {
    if (daysLeft == null) return null;
    if (daysLeft < 0) return 'Hết hạn ${-daysLeft} ngày';
    if (daysLeft == 0) return 'Hết hạn hôm nay';
    return 'Còn $daysLeft ngày';
  }
}
