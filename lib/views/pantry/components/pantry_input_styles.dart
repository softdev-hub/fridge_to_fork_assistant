import 'package:flutter/material.dart';
import 'pantry_constants.dart';

/// Tạo InputDecoration chung cho các text fields trong Pantry.
InputDecoration pantryInputDecoration(
  String hint,
  bool isDark, {
  bool enabled = true,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
    filled: true,
    fillColor: !enabled
        ? (isDark ? Colors.grey[700] : Colors.grey[100])
        : (isDark ? Colors.grey[800] : Colors.white),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(PantryConstants.borderRadius),
      borderSide: BorderSide(
        color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(PantryConstants.borderRadius),
      borderSide: BorderSide(
        color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(PantryConstants.borderRadius),
      borderSide: const BorderSide(color: PantryConstants.primaryColor),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(PantryConstants.borderRadius),
      borderSide: BorderSide(
        color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );
}
