/// Helper to extract user-friendly error messages
class ErrorMessageHelper {
  static String getUserFriendlyMessage(dynamic error) {
    final errorString = error.toString();
    
    // Network errors
    if (errorString.contains('fetch failed') ||
        errorString.contains('Failed host lookup') ||
        errorString.contains('Connection refused') ||
        errorString.contains('SocketException') ||
        errorString.contains('NetworkException')) {
      return 'Cannot connect to server. Please check if the backend is running on port 4000.';
    }
    
    // Timeout errors
    if (errorString.contains('timeout') || errorString.contains('TimeoutException')) {
      return 'Request timed out. Please check your internet connection.';
    }
    
    // Authentication errors
    if (errorString.contains('401') ||
        errorString.contains('Unauthorized') ||
        errorString.contains('AuthenticationException')) {
      return 'Authentication failed. Please logout and login again.';
    }
    
    // Server errors
    if (errorString.contains('500') ||
        errorString.contains('ServerException') ||
        errorString.contains('Internal Server Error')) {
      return 'Server error. Please try again later.';
    }
    
    // Type errors (usually network related)
    if (errorString.contains('TypeError')) {
      return 'Network error. Please check if the backend server is running.';
    }
    
    // Generic error - clean up the message
    return errorString
        .replaceAll('Exception: ', '')
        .replaceAll('TypeError: ', '')
        .replaceAll('Error: ', '');
  }
}

