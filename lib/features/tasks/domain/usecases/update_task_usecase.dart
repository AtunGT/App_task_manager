import '../entities/task.dart';
import '../repositories/task_repository.dart';

class UpdateTaskUsecase {
  final TaskRepository repository;
  UpdateTaskUsecase(this.repository);

  Future<Task> call({
    required String id,
    required String title,
    required String description,
    required String dueDate,
    String? reminderTime,
  }) =>
      repository.updateTask(
        id: id,
        title: title,
        description: description,
        dueDate: dueDate,
        reminderTime: reminderTime,
      );
}
