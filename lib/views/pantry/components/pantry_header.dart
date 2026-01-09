import 'dart:ui';
import 'package:flutter/material.dart';
import 'pantry_constants.dart';

/// Header chung cho các màn hình Pantry với hiệu ứng blur.
class PantryHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool showBackButton;
  final EdgeInsets? padding;

  const PantryHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
    this.showBackButton = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? PantryConstants.backgroundDark
        : PantryConstants.backgroundColor;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          color: bgColor.withAlpha(204),
          child: Row(
            children: [
              if (showBackButton)
                IconButton(
                  onPressed: onBack ?? () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.arrow_back,
                    color: isDark ? Colors.grey[200] : Colors.grey[800],
                  ),
                )
              else
                const SizedBox(width: 32),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey[100] : Colors.grey[900],
                  ),
                ),
              ),
              if (trailing != null)
                trailing!
              else
                const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }
}
