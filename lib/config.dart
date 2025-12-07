import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrlKey = 'SUPABASE_URL';
const _supabaseAnonKey = 'SUPABASE_ANON_KEY';

/// Loads environment variables before accessing Supabase credentials.
Future<void> ensureEnvLoaded() async {
  if (!dotenv.isInitialized) {
    await dotenv.load(fileName: '.env');
  }
}

/// Returns the configured Supabase URL read from `.env`.
String get supabaseUrl => dotenv.env[_supabaseUrlKey] ?? '';

/// Returns the configured Supabase anon/public API key from `.env`.
String get supabaseAnonKey => dotenv.env[_supabaseAnonKey] ?? '';

/// Initializes the Supabase client using the values from `.env`.
Future<void> initSupabase() async {
  await ensureEnvLoaded();

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw StateError(
      'Supabase URL or anon key is missing. Please populate `.env` based on `.env.example`.',
    );
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
}

/// Convenient accessor for the initialized Supabase client.
SupabaseClient get supabase => Supabase.instance.client;
