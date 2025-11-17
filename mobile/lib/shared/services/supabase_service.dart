import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/app_config.dart';

class SupabaseService {
  static SupabaseClient? _client;

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call SupabaseService.initialize() first.');
    }
    return _client!;
  }

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
      storageOptions: const StorageClientOptions(
        retryAttempts: 3,
      ),
    );

    _client = Supabase.instance.client;
  }

  // Auth helpers
  static User? get currentUser => client.auth.currentUser;
  static String? get currentUserId => client.auth.currentUser?.id;
  static bool get isAuthenticated => client.auth.currentUser != null;

  // Stream of auth state changes
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // Sign out
  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}
