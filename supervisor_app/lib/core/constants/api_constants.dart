/// API Constants for Supervisor App
class ApiConstants {
  // Base URL - Should be configured via environment variables
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000/api',
  );

  // Auth endpoints
  static const String login = '/supervisor/auth/login';

  // Supervisor endpoints
  static const String workers = '/supervisor/workers';
  static const String workerDetail = '/supervisor/workers';
  static const String updateWorker = '/supervisor/workers';
  static const String assignProject = '/supervisor/workers';
  static const String removeProject = '/supervisor/workers';

  // Attendance endpoints
  static const String attendance = '/supervisor/attendance';
  static const String attendanceOverride = '/supervisor/attendance/override';

  // Project endpoints
  static const String projects = '/supervisor/projects';
  static const String projectDetail = '/supervisor/projects';
  static const String projectTasks = '/supervisor/projects';
  static const String createTask = '/supervisor/projects';
  static const String updateTask = '/supervisor/tasks';
  static const String projectProgress = '/supervisor/projects';

  // Dashboard endpoint
  static const String dashboard = '/supervisor/dashboard';

  // Notifications endpoint
  static const String notifications = '/supervisor/notifications';
  static const String markNotificationRead = '/supervisor/notifications';

  // Headers
  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}

