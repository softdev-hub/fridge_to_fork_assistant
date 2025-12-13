import 'package:flutter/material.dart';

/// Label widget cho các form fields trong Pantry.
class PantryLabel extends StatelessWidget {
  final String text;

  const PantryLabel({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.grey[300] : Colors.grey[700],
      ),
    );
  }
}
