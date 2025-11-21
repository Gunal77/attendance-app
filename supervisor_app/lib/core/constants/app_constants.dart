/// App-wide Constants
class AppConstants {
  // Storage keys
  static const String authTokenKey = 'supervisor_auth_token';
  static const String supervisorDataKey = 'supervisor_data';
  static const String isLoggedInKey = 'is_logged_in';

  // Database
  static const String databaseName = 'supervisor_app.db';
  static const int databaseVersion = 1;

  // Pagination
  static const int defaultPageSize = 20;

  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayDateTimeFormat = 'MMM dd, yyyy HH:mm';

  // Sync intervals
  static const Duration syncInterval = Duration(minutes: 5);
  static const Duration retryDelay = Duration(seconds: 3);
  static const int maxRetries = 3;
}

