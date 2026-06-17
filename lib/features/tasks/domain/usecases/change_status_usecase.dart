import '../repositories/task_repository.dart';

class ChangeStatusUsecase {
  final TaskRepository repository;
  ChangeStatusUsecase(this.repository);

  Future<void> call(String id, String status) => repository.changeStatus(id, status);
}
