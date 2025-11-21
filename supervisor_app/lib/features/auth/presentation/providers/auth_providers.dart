import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../../data/models/supervisor_model.dart';

// Providers
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(apiClientProvider));
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource();
});

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
    apiClient: ref.watch(apiClientProvider),
  );
});

final authStateProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  final result = await repository.isLoggedIn();
  if (result is Success<bool>) {
    return result.data;
  } else {
    return false;
  }
});

final currentSupervisorProvider = FutureProvider<SupervisorModel?>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  final result = await repository.getCachedSupervisor();
  if (result is Success<SupervisorModel?>) {
    return result.data;
  } else {
    return null;
  }
});

// Login Provider
final loginProvider = FutureProvider.family<SupervisorModel?, LoginParams>((ref, params) async {
  final repository = ref.watch(authRepositoryProvider);
  final result = await repository.login(params.email, params.password);
  if (result is Success<SupervisorModel>) {
    return result.data;
  } else if (result is Failure<SupervisorModel>) {
    throw result.error;
  }
  return null;
});

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}

