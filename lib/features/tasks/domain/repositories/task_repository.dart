import '../entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks({String? status});
  Future<Task> createTask({
    required String title,
    required String description,
    required String dueDate,
    String? reminderTime,
  });
  Future<Task> updateTask({
    required String id,
    required String title,
    required String description,
    required String dueDate,
    String? reminderTime,
  });
  Future<void> deleteTask(String id);
  Future<void> changeStatus(String id, String status);
}
