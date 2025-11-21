import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../data/models/supervisor_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exception.dart';

/// Local data source for authentication
class AuthLocalDataSource {
  Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.authTokenKey, token);
    } catch (e) {
      throw CacheException('Failed to save token: ${e.toString()}');
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.authTokenKey);
    } catch (e) {
      throw CacheException('Failed to get token: ${e.toString()}');
    }
  }

  Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.authTokenKey);
      await prefs.remove(AppConstants.supervisorDataKey);
      await prefs.setBool(AppConstants.isLoggedInKey, false);
    } catch (e) {
      throw CacheException('Failed to clear token: ${e.toString()}');
    }
  }

  Future<void> saveSupervisorData(SupervisorModel supervisor) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.supervisorDataKey,
        jsonEncode(supervisor.toJson()),
      );
      await prefs.setBool(AppConstants.isLoggedInKey, true);
    } catch (e) {
      throw CacheException('Failed to save supervisor data: ${e.toString()}');
    }
  }

  Future<SupervisorModel?> getSupervisorData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(AppConstants.supervisorDataKey);
      if (data == null) return null;
      return SupervisorModel.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (e) {
      throw CacheException('Failed to get supervisor data: ${e.toString()}');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(AppConstants.isLoggedInKey) ?? false;
    } catch (e) {
      return false;
    }
  }
}

