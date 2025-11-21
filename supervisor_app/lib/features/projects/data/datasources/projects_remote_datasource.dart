import '../../../../data/models/project_model.dart';
import '../../../../data/models/task_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exception.dart';

/// Remote data source for projects
class ProjectsRemoteDataSource {
  final ApiClient apiClient;

  ProjectsRemoteDataSource(this.apiClient);

  Future<List<ProjectModel>> getProjects() async {
    try {
      final response = await apiClient.get(ApiConstants.projects);
      
      if (response.data == null) {
        throw ServerException('Invalid response from server');
      }

      final data = response.data as Map<String, dynamic>;
      final projectsList = data['projects'] as List<dynamic>? ?? [];

      return projectsList
          .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on AppException catch (e) {
      print('⚠️ AppException in getProjects: $e');
      rethrow;
    } catch (e) {
      print('⚠️ Unexpected error in getProjects: $e, type: ${e.runtimeType}');
      // Convert any error to AppException
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('Failed to fetch projects: ${e.toString()}');
    }
  }

  Future<ProjectModel> getProjectById(String projectId) async {
    try {
      final response = await apiClient.get('${ApiConstants.projectDetail}/$projectId');
      
      if (response.data == null) {
        throw ServerException('Invalid response from server');
      }

      final data = response.data as Map<String, dynamic>;
      final projectData = data['project'] as Map<String, dynamic>?;

      if (projectData == null) {
        throw ServerException('Project not found');
      }

      return ProjectModel.fromJson(projectData);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to fetch project: ${e.toString()}');
    }
  }

  Future<List<TaskModel>> getProjectTasks(String projectId) async {
    try {
      final response = await apiClient.get('${ApiConstants.projectTasks}/$projectId/tasks');
      
      if (response.data == null) {
        throw ServerException('Invalid response from server');
      }

      final data = response.data as Map<String, dynamic>;
      final tasksList = data['tasks'] as List<dynamic>? ?? [];

      return tasksList
          .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to fetch tasks: ${e.toString()}');
    }
  }
}

