import '../../../../core/utils/result.dart';
import '../../../../core/errors/exception.dart';
import '../../../../core/errors/failures.dart' as failures;
import '../../../../core/utils/error_handler.dart';
import '../../../../data/models/worker_model.dart';
import '../datasources/workers_remote_datasource.dart';

/// Workers Repository Implementation
class WorkersRepositoryImpl {
  final WorkersRemoteDataSource remoteDataSource;

  WorkersRepositoryImpl({required this.remoteDataSource});

  Future<Result<List<WorkerModel>>> getWorkers() async {
    try {
      final workers = await remoteDataSource.getWorkers();
      return Success(workers);
    } on AppException catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Failure.fromFailure(failure);
    } catch (e) {
      return Failure.fromFailure(
        failures.UnknownFailure('Failed to fetch workers: ${e.toString()}'),
      );
    }
  }

  Future<Result<WorkerModel>> getWorkerById(String workerId) async {
    try {
      final worker = await remoteDataSource.getWorkerById(workerId);
      return Success(worker);
    } on AppException catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Failure.fromFailure(failure);
    } catch (e) {
      return Failure.fromFailure(
        failures.UnknownFailure('Failed to fetch worker: ${e.toString()}'),
      );
    }
  }

  Future<Result<WorkerModel>> updateWorker(
    String workerId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final worker = await remoteDataSource.updateWorker(workerId, updates);
      return Success(worker);
    } on AppException catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Failure.fromFailure(failure);
    } catch (e) {
      return Failure.fromFailure(
        failures.UnknownFailure('Failed to update worker: ${e.toString()}'),
      );
    }
  }

  Future<Result<WorkerModel>> assignProject(
    String workerId,
    String projectId,
  ) async {
    try {
      final worker = await remoteDataSource.assignProject(workerId, projectId);
      return Success(worker);
    } on AppException catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Failure.fromFailure(failure);
    } catch (e) {
      return Failure.fromFailure(
        failures.UnknownFailure('Failed to assign project: ${e.toString()}'),
      );
    }
  }

  Future<Result<WorkerModel>> removeProject(String workerId) async {
    try {
      final worker = await remoteDataSource.removeProject(workerId);
      return Success(worker);
    } on AppException catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Failure.fromFailure(failure);
    } catch (e) {
      return Failure.fromFailure(
        failures.UnknownFailure('Failed to remove project: ${e.toString()}'),
      );
    }
  }
}
