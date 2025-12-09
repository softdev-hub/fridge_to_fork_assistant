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
}
