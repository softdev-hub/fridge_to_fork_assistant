import 'package:flutter/material.dart';
import 'pantry_constants.dart';
import 'pantry_label.dart';

/// Date field widget với date picker cho Pantry forms.
class PantryDateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final String? errorText;

  const PantryDateField({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PantryLabel(text: label),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(PantryConstants.borderRadius),
              border: Border.all(
                color: hasError
                    ? Colors.red
                    : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}'
                      : 'Chọn ngày',
                  style: TextStyle(
                    color: date != null
                        ? (isDark ? Colors.grey[100] : Colors.grey[900])
                        : (isDark ? Colors.grey[500] : Colors.grey[400]),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                ),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  /// Hiển thị date picker dialog.
  static Future<DateTime?> showPicker(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                const ColorScheme.light(primary: PantryConstants.primaryColor),
          ),
          child: child!,
        );
      },
    );
  }
}
