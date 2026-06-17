import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks({String? status});
  Future<TaskModel> createTask({
    required String title,
    required String description,
    required String dueDate,
    String? reminderTime,
  });
  Future<TaskModel> updateTask({
    required String id,
    required String title,
    required String description,
    required String dueDate,
    String? reminderTime,
  });
  Future<void> deleteTask(String id);
  Future<void> changeStatus(String id, String status);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final DioClient client;
  TaskRemoteDataSourceImpl(this.client);

  @override
  Future<List<TaskModel>> getTasks({String? status}) async {
    final response = await client.dio.get(
      ApiConstants.tasks,
      queryParameters: status != null ? {'status': status} : null,
    );
    return (response.data as List)
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TaskModel> createTask({
    required String title,
    required String description,
    required String dueDate,
    String? reminderTime,
  }) async {
    final response = await client.dio.post(ApiConstants.tasks, data: {
      'title': title,
      'description': description,
      'due_date': dueDate,
      if (reminderTime != null) 'reminder_time': reminderTime,
    });
    return TaskModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TaskModel> updateTask({
    required String id,
    required String title,
    required String description,
    required String dueDate,
    String? reminderTime,
  }) async {
    final response = await client.dio.put('${ApiConstants.tasks}/$id', data: {
      'title': title,
      'description': description,
      'due_date': dueDate,
      if (reminderTime != null) 'reminder_time': reminderTime,
    });
    return TaskModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteTask(String id) async {
    await client.dio.delete('${ApiConstants.tasks}/$id');
  }

  @override
  Future<void> changeStatus(String id, String status) async {
    await client.dio.patch('${ApiConstants.tasks}/$id/status', data: {'status': status});
  }
}
