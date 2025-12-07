/// Shared application constants that can be reused across widgets and controllers
class AppConstants {
  AppConstants();

  /// Display name of the application.
  static const String appName = 'Bếp Trợ Lý – Fridge-to-Fork Assistant';

  /// Environment variable keys used by Supabase configuration
  static const String supabaseUrlEnv = 'SUPABASE_URL';
  static const String supabaseAnonKeyEnv = 'SUPABASE_ANON_KEY';

  /// Days before expiration when a warning should be shown to the user
  static const int expirationWarningDays = 3;
}
