import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
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
  final ApiClient client;
  TaskRemoteDataSourceImpl(this.client);

  @override
  Future<List<TaskModel>> getTasks({String? status}) async {
    final data = await client.get(
      ApiConstants.tasks,
      queryParameters: status != null ? {'status': status} : null,
    );
    return (data as List)
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
    final data = await client.post(ApiConstants.tasks, body: {
      'title': title,
      'description': description,
      'due_date': dueDate,
      if (reminderTime != null) 'reminder_time': reminderTime,
    });
    return TaskModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<TaskModel> updateTask({
    required String id,
    required String title,
    required String description,
    required String dueDate,
    String? reminderTime,
  }) async {
    final data = await client.put('${ApiConstants.tasks}/$id', body: {
      'title': title,
      'description': description,
      'due_date': dueDate,
      if (reminderTime != null) 'reminder_time': reminderTime,
    });
    return TaskModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteTask(String id) async {
    await client.delete('${ApiConstants.tasks}/$id');
  }

  @override
  Future<void> changeStatus(String id, String status) async {
    await client.patch('${ApiConstants.tasks}/$id/status', body: {'status': status});
  }
}
