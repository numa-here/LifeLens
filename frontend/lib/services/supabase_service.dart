import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _isMockMode = true;
  bool get isMockMode => _isMockMode;

  SupabaseClient? _client;
  SupabaseClient? get client => _client;

  /// Initializes Supabase with project credentials.
  /// Falls back smoothly to Mock Mode if keys are placeholders or invalid.
  Future<void> initialize({
    String? supabaseUrl,
    String? supabaseAnonKey,
  }) async {
    final url = supabaseUrl ?? const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    final anonKey = supabaseAnonKey ?? const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

    final bool hasValidCredentials = url.isNotEmpty &&
        anonKey.isNotEmpty &&
        !url.contains('your-project-id') &&
        !anonKey.contains('your-supabase-anon-key');

    if (hasValidCredentials) {
      try {
        await Supabase.initialize(
          url: url,
          // ignore: deprecated_member_use
          anonKey: anonKey,
          debug: kDebugMode,
        );
        _client = Supabase.instance.client;
        _isMockMode = false;
        debugPrint('[LifeLens] Supabase successfully initialized in LIVE mode');
        return;
      } catch (e) {
        debugPrint('[LifeLens] Supabase init failed: $e. Falling back to MOCK mode.');
      }
    } else {
      debugPrint('[LifeLens] Supabase credentials unconfigured. Running in MOCK/DEMO mode for Numa.');
    }

    _isMockMode = true;
  }

  void forceMockMode(bool enable) {
    _isMockMode = enable;
  }
}
