import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/exception.dart';
import '../../../../core/errors/failures.dart' as failures;
import '../../../../core/utils/error_handler.dart';
import '../../../../data/models/supervisor_model.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';

/// Authentication Repository Implementation
class AuthRepositoryImpl {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final ApiClient apiClient;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.apiClient,
  });

  Future<Result<SupervisorModel>> login(String email, String password) async {
    try {
      final response = await remoteDataSource.login(email, password);
      
      final token = response['token'] as String;
      final userData = response['user'] as Map<String, dynamic>;

      // Save token to API client
      await apiClient.setToken(token);
      
      // Save token locally
      await localDataSource.saveToken(token);

      // Create supervisor model
      final supervisor = SupervisorModel(
        id: userData['id'] as String,
        name: userData['name'] as String,
        email: userData['email'] as String,
        phone: userData['phone'] as String?,
      );

      // Save supervisor data locally
      await localDataSource.saveSupervisorData(supervisor);

      return Success(supervisor);
    } on AppException catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Failure.fromFailure(failure);
    } catch (e) {
      return Failure.fromFailure(failures.UnknownFailure('Login failed: ${e.toString()}'));
    }
  }

  Future<Result<void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearToken();
      await apiClient.clearToken();
      return const Success(null);
    } on AppException catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Failure.fromFailure(failure);
    } catch (e) {
      return Failure.fromFailure(failures.UnknownFailure('Logout failed: ${e.toString()}'));
    }
  }

  Future<Result<SupervisorModel?>> getCachedSupervisor() async {
    try {
      final supervisor = await localDataSource.getSupervisorData();
      if (supervisor != null) {
        final token = await localDataSource.getToken();
        if (token != null) {
          await apiClient.setToken(token);
        }
      }
      return Success(supervisor);
    } on AppException catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Failure.fromFailure(failure);
    } catch (e) {
      return Failure.fromFailure(failures.UnknownFailure('Failed to get cached supervisor: ${e.toString()}'));
    }
  }

  Future<Result<bool>> isLoggedIn() async {
    try {
      final isLoggedIn = await localDataSource.isLoggedIn();
      return Success(isLoggedIn);
    } catch (e) {
      return Failure.fromFailure(failures.UnknownFailure('Failed to check login status: ${e.toString()}'));
    }
  }
}

