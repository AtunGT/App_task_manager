import '../entities/task.dart';
import '../repositories/task_repository.dart';

class CreateTaskUsecase {
  final TaskRepository repository;
  CreateTaskUsecase(this.repository);

  Future<Task> call({
    required String title,
    required String description,
    required String dueDate,
    String? reminderTime,
  }) =>
      repository.createTask(
        title: title,
        description: description,
        dueDate: dueDate,
        reminderTime: reminderTime,
      );
}
