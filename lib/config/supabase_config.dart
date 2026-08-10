/// Holds configuration constants for Supabase Auth, PostgreSQL Database, and Storage.
/// Values can be overridden at build time via `--dart-define` environment flags or fall back to default credentials.
class SupabaseConfig {
  /// The public API URL of your Supabase project instance.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ltqkvbquqyfzngpjqbot.supabase.co',
  );

  /// The public anonymous API key for authenticating requests against Supabase.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_LmQGqyyTo-6u3e4IqtKHlQ_txHzfBHK',
  );

  /// Helper getter returning true if Supabase URL and anon key are populated with valid credentials.
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      supabaseUrl != 'YOUR_SUPABASE_URL' &&
      supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY';
}
