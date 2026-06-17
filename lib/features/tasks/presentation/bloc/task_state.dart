import '../../domain/entities/task.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TasksLoaded extends TaskState {
  final List<Task> tasks;
  TasksLoaded(this.tasks);
}

class TaskOperationSuccess extends TaskState {}

class TaskFailure extends TaskState {
  final String message;
  TaskFailure(this.message);
}
