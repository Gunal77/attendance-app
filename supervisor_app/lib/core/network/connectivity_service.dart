import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Service to check network connectivity
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _connectionChecker = InternetConnectionChecker();

  Stream<bool> get connectivityStream async* {
    yield* _connectivity.onConnectivityChanged.asyncMap((result) async {
      if (result == ConnectivityResult.none) {
        return false;
      }
      return await _connectionChecker.hasConnection;
    });
  }

  Future<bool> hasConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    return await _connectionChecker.hasConnection;
  }
}

