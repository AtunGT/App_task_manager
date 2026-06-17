import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTasksUsecase {
  final TaskRepository repository;
  GetTasksUsecase(this.repository);

  Future<List<Task>> call({String? status}) => repository.getTasks(status: status);
}
