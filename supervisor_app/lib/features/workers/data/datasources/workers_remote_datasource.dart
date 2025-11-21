import '../../../../data/models/worker_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exception.dart';

/// Remote data source for workers
class WorkersRemoteDataSource {
  final ApiClient apiClient;

  WorkersRemoteDataSource(this.apiClient);

  Future<List<WorkerModel>> getWorkers() async {
    try {
      final response = await apiClient.get(ApiConstants.workers);
      
      if (response.data == null) {
        throw ServerException('Invalid response from server');
      }

      final data = response.data as Map<String, dynamic>;
      final workersList = data['workers'] as List<dynamic>? ?? [];

      print('Workers response: $data');
      print('Workers list length: ${workersList.length}');

      final workers = <WorkerModel>[];
      for (final item in workersList) {
        try {
          if (item is Map<String, dynamic>) {
            // The backend already flattens the structure, so we can use it directly
            // But we need to handle the project field properly
            final workerData = Map<String, dynamic>.from(item);
            
            // Ensure project is properly set (backend sends it as 'project' or 'projects')
            if (workerData['project'] == null && workerData['projects'] != null) {
              workerData['project'] = workerData['projects'];
            }
            
            workers.add(WorkerModel.fromJson(workerData));
          }
        } catch (e) {
          print('Error parsing worker: $e, item: $item');
          // Continue with next worker
        }
      }

      return workers;
    } on AppException {
      rethrow;
    } catch (e) {
      print('Get workers error: $e');
      throw ServerException('Failed to fetch workers: ${e.toString()}');
    }
  }

  Future<WorkerModel> getWorkerById(String workerId) async {
    try {
      final response = await apiClient.get('${ApiConstants.workerDetail}/$workerId');
      
      if (response.data == null) {
        throw ServerException('Invalid response from server');
      }

      final data = response.data as Map<String, dynamic>;
      final workerData = data['worker'] as Map<String, dynamic>?;

      if (workerData == null) {
        throw ServerException('Worker not found');
      }

      return WorkerModel.fromJson(workerData);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to fetch worker: ${e.toString()}');
    }
  }

  Future<WorkerModel> updateWorker(String workerId, Map<String, dynamic> updates) async {
    try {
      final response = await apiClient.put(
        '${ApiConstants.updateWorker}/$workerId',
        data: updates,
      );
      
      if (response.data == null) {
        throw ServerException('Invalid response from server');
      }

      final data = response.data as Map<String, dynamic>;
      final workerData = data['worker'] as Map<String, dynamic>?;

      if (workerData == null) {
        throw ServerException('Failed to update worker');
      }

      return WorkerModel.fromJson(workerData);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to update worker: ${e.toString()}');
    }
  }

  Future<WorkerModel> assignProject(String workerId, String projectId) async {
    try {
      final response = await apiClient.post(
        '${ApiConstants.assignProject}/$workerId/assign-project',
        data: {'project_id': projectId},
      );
      
      if (response.data == null) {
        throw ServerException('Invalid response from server');
      }

      final data = response.data as Map<String, dynamic>;
      final workerData = data['worker'] as Map<String, dynamic>?;

      if (workerData == null) {
        throw ServerException('Failed to assign project');
      }

      return WorkerModel.fromJson(workerData);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to assign project: ${e.toString()}');
    }
  }

  Future<WorkerModel> removeProject(String workerId) async {
    try {
      final response = await apiClient.delete(
        '${ApiConstants.removeProject}/$workerId/remove-project',
      );
      
      if (response.data == null) {
        throw ServerException('Invalid response from server');
      }

      final data = response.data as Map<String, dynamic>;
      final workerData = data['worker'] as Map<String, dynamic>?;

      if (workerData == null) {
        throw ServerException('Failed to remove project');
      }

      return WorkerModel.fromJson(workerData);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to remove project: ${e.toString()}');
    }
  }
}

