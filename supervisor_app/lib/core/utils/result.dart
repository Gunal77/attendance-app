import '../errors/failures.dart' as failures;

/// Result class for handling success/failure states
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final Exception error;
  const Failure(this.error);
  
  // Helper constructor for failures.Failure
  factory Failure.fromFailure(dynamic failure) {
    if (failure is Exception) {
      return Failure(failure);
    }
    // Convert failures.Failure to Exception
    if (failure is failures.Failure) {
      return Failure(Exception(failure.message));
    }
    return Failure(Exception(failure.toString()));
  }
}

extension ResultExtension<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;
  Exception? get errorOrNull => isFailure ? (this as Failure<T>).error : null;

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Exception error) onFailure,
  }) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).data);
    } else {
      return onFailure((this as Failure<T>).error);
    }
  }
}

