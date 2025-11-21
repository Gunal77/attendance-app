import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exception.dart';

/// Remote data source for authentication
class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource(this.apiClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await apiClient.post(
        ApiConstants.login,
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      if (response.data == null) {
        throw ServerException('Invalid response from server');
      }

      final data = response.data as Map<String, dynamic>;
      
      if (data['token'] == null) {
        throw AuthenticationException('Login failed: No token received');
      }

      return data;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Login failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    // Token is removed client-side
    await apiClient.clearToken();
  }
}

