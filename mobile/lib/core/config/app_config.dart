import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';

  // Supabase
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // API Endpoints
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
  static String get mlServiceUrl => dotenv.env['ML_SERVICE_URL'] ?? 'http://localhost:8000';

  // OAuth
  static String get googleClientIdIos => dotenv.env['GOOGLE_OAUTH_CLIENT_ID_IOS'] ?? '';
  static String get googleClientIdAndroid => dotenv.env['GOOGLE_OAUTH_CLIENT_ID_ANDROID'] ?? '';
  static String get appleClientId => dotenv.env['APPLE_OAUTH_CLIENT_ID'] ?? '';

  // Firebase
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseAppIdIos => dotenv.env['FIREBASE_APP_ID_IOS'] ?? '';
  static String get firebaseAppIdAndroid => dotenv.env['FIREBASE_APP_ID_ANDROID'] ?? '';
  static String get firebaseMessagingSenderId => dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

  // Analytics
  static String get mixpanelToken => dotenv.env['MIXPANEL_TOKEN'] ?? '';
  static String get sentryDsn => dotenv.env['SENTRY_DSN'] ?? '';

  // Feature Flags
  static bool get enableSocialFeatures => dotenv.env['ENABLE_SOCIAL_FEATURES'] == 'true';
  static bool get enablePoseDetection => dotenv.env['ENABLE_POSE_DETECTION'] == 'true';
  static bool get enableMLRecommendations => dotenv.env['ENABLE_ML_RECOMMENDATIONS'] == 'true';

  // App Info
  static const String appName = 'Health & Fitness';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@healthapp.com';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache
  static const int defaultCacheDuration = 3600; // 1 hour in seconds
  static const int quoteCacheDuration = 86400; // 24 hours

  // File Upload
  static const int maxImageSizeMB = 5;
  static const int maxVideoSizeMB = 50;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];

  // Timeouts
  static const int apiTimeoutSeconds = 30;
  static const int uploadTimeoutSeconds = 120;
}
