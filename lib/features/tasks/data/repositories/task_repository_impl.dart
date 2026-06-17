import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  TaskRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Task>> getTasks({String? status}) =>
      remoteDataSource.getTasks(status: status);

  @override
  Future<Task> createTask({
    required String title,
    required String description,
    required String dueDate,
    String? reminderTime,
  }) =>
      remoteDataSource.createTask(
        title: title,
        description: description,
        dueDate: dueDate,
        reminderTime: reminderTime,
      );

  @override
  Future<Task> updateTask({
    required String id,
    required String title,
    required String description,
    required String dueDate,
    String? reminderTime,
  }) =>
      remoteDataSource.updateTask(
        id: id,
        title: title,
        description: description,
        dueDate: dueDate,
        reminderTime: reminderTime,
      );

  @override
  Future<void> deleteTask(String id) => remoteDataSource.deleteTask(id);

  @override
  Future<void> changeStatus(String id, String status) =>
      remoteDataSource.changeStatus(id, status);
}
