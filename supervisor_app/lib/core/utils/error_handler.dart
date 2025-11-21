import '../errors/exception.dart';
import '../errors/failures.dart';

/// Error Handler utility
class ErrorHandler {
  static Failure handleException(Exception exception) {
    if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    } else if (exception is ServerException) {
      return ServerFailure(exception.message, statusCode: exception.statusCode);
    } else if (exception is AuthenticationException) {
      return AuthenticationFailure(exception.message);
    } else if (exception is CacheException) {
      return CacheFailure(exception.message);
    } else if (exception is ValidationException) {
      return ValidationFailure(exception.message);
    } else {
      return UnknownFailure(exception.toString());
    }
  }

  static String getErrorMessage(Exception exception) {
    return handleException(exception).message;
  }

  static String getUserFriendlyMessage(Exception exception) {
    final failure = handleException(exception);
    
    if (failure is NetworkFailure) {
      return 'Please check your internet connection and try again.';
    } else if (failure is ServerFailure) {
      if (failure.statusCode == 404) {
        return 'The requested resource was not found.';
      } else if (failure.statusCode != null && failure.statusCode! >= 500) {
        return 'Server error. Please try again later.';
      }
      return failure.message;
    } else if (failure is AuthenticationFailure) {
      return 'Authentication failed. Please login again.';
    }
    
    return failure.message;
  }
}

