import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get url => _normalizeUrl(dotenv.env['SUPABASE_URL'] ?? '');
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static String _normalizeUrl(String raw) {
    final cleaned = raw.trim();
    if (cleaned.isEmpty) return '';

    // Accept both project URL and REST endpoint URL from user env input.
    var url = cleaned.replaceAll(RegExp(r'/+$'), '');
    url = url.replaceAll(RegExp(r'/rest/v1/?$'), '');
    return url;
  }
}
