/// Date utility functions for the app

class DateUtils {
  /// Compare two nullable dates for sorting
  /// Returns: negative if a < b, positive if a > b, 0 if equal
  /// Null dates are sorted to the end
  static int compareNullableDates(
    DateTime? a,
    DateTime? b, {
    bool ascending = true,
  }) {
    if (a == null && b == null) return 0;
    if (a == null) return ascending ? 1 : -1;
    if (b == null) return ascending ? -1 : 1;
    return ascending ? a.compareTo(b) : b.compareTo(a);
  }

  /// Sort a list by a date field with null safety
  /// Items with null dates are placed at the end
  static void sortByDate<T>(
    List<T> items,
    DateTime? Function(T) getDate, {
    bool ascending = true,
  }) {
    items.sort(
      (a, b) =>
          compareNullableDates(getDate(a), getDate(b), ascending: ascending),
    );
  }

  /// Format date as dd/MM/yyyy
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Calculate days until a date (negative if past)
  static int? daysUntil(DateTime? date) {
    if (date == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    return targetDate.difference(today).inDays;
  }

  /// Check if a date is expired (before today)
  static bool isExpired(DateTime? date) {
    if (date == null) return false;
    final daysLeft = daysUntil(date);
    return daysLeft != null && daysLeft < 0;
  }

  /// Check if date is expiring soon (within specified days)
  static bool isExpiringSoon(DateTime? date, {int withinDays = 3}) {
    if (date == null) return false;
    final daysLeft = daysUntil(date);
    return daysLeft != null && daysLeft >= 0 && daysLeft <= withinDays;
  }

  /// Get expiry status text in Vietnamese
  static String? getExpiryText(DateTime? date) {
    final daysLeft = daysUntil(date);
    if (daysLeft == null) return null;
    if (daysLeft < 0) return 'Hết hạn ${-daysLeft} ngày';
    if (daysLeft == 0) return 'Hết hạn hôm nay';
    return 'Còn $daysLeft ngày';
  }

  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      return 'Chào buổi sáng';
    } else if (hour >= 11 && hour < 13) {
      return 'Chào buổi trưa';
    } else if (hour >= 13 && hour < 18) {
      return 'Chào buổi chiều';
    } else {
      return 'Chào buổi tối';
    }
  }

  // ============= VALIDATION FUNCTIONS =============

  /// Validate purchase date
  /// Returns error message if invalid, null if valid
  static String? validatePurchaseDate(
    DateTime? purchaseDate, {
    bool required = true,
  }) {
    if (purchaseDate == null) {
      return required ? 'Vui lòng chọn ngày mua' : null;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final purchase = DateTime(
      purchaseDate.year,
      purchaseDate.month,
      purchaseDate.day,
    );

    // Purchase date cannot be in the future
    if (purchase.isAfter(today)) {
      return 'Ngày mua không thể là ngày trong tương lai';
    }

    // Purchase date cannot be too old (more than 5 years)
    final fiveYearsAgo = today.subtract(const Duration(days: 365 * 5));
    if (purchase.isBefore(fiveYearsAgo)) {
      return 'Ngày mua không hợp lệ (quá 5 năm)';
    }

    return null;
  }

  /// Validate expiry date
  /// Returns error message if invalid, null if valid
  static String? validateExpiryDate(
    DateTime? expiryDate, {
    bool required = true,
  }) {
    if (expiryDate == null) {
      return required ? 'Vui lòng chọn hạn sử dụng' : null;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

    // Expiry date cannot be too far in the future (more than 10 years)
    final tenYearsLater = today.add(const Duration(days: 365 * 10));
    if (expiry.isAfter(tenYearsLater)) {
      return 'Hạn sử dụng không hợp lệ (quá 10 năm)';
    }

    return null;
  }

  /// Validate that expiry date is after purchase date
  /// Returns error message if invalid, null if valid
  static String? validateDateRange(
    DateTime? purchaseDate,
    DateTime? expiryDate,
  ) {
    if (purchaseDate == null || expiryDate == null) return null;

    final purchase = DateTime(
      purchaseDate.year,
      purchaseDate.month,
      purchaseDate.day,
    );
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

    if (expiry.isBefore(purchase)) {
      return 'Hạn sử dụng phải sau ngày mua';
    }

    if (expiry.isAtSameMomentAs(purchase)) {
      return 'Hạn sử dụng không thể trùng với ngày mua';
    }

    return null;
  }

  /// Validate all dates together
  /// Returns first error found, null if all valid
  static String? validateDates(DateTime? purchaseDate, DateTime? expiryDate) {
    // Validate purchase date
    final purchaseError = validatePurchaseDate(purchaseDate);
    if (purchaseError != null) return purchaseError;

    // Validate expiry date
    final expiryError = validateExpiryDate(expiryDate);
    if (expiryError != null) return expiryError;

    // Validate date range
    final rangeError = validateDateRange(purchaseDate, expiryDate);
    if (rangeError != null) return rangeError;

    return null;
  }

  /// Check if a date string is valid format (dd/MM/yyyy)
  static bool isValidDateFormat(String dateString) {
    final regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!regex.hasMatch(dateString)) return false;

    final parts = dateString.split('/');
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) return false;
    if (month < 1 || month > 12) return false;
    if (day < 1 || day > 31) return false;
    if (year < 1900 || year > 2100) return false;

    // Check valid day for month
    final daysInMonth = DateTime(year, month + 1, 0).day;
    if (day > daysInMonth) return false;

    return true;
  }

  /// Parse date from string (dd/MM/yyyy)
  static DateTime? parseDate(String dateString) {
    if (!isValidDateFormat(dateString)) return null;

    final parts = dateString.split('/');
    return DateTime(
      int.parse(parts[2]), // year
      int.parse(parts[1]), // month
      int.parse(parts[0]), // day
    );
  }
}
