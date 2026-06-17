import '../repositories/task_repository.dart';

class DeleteTaskUsecase {
  final TaskRepository repository;
  DeleteTaskUsecase(this.repository);

  Future<void> call(String id) => repository.deleteTask(id);
}
