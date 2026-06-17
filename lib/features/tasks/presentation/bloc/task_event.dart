abstract class TaskEvent {}

class LoadTasks extends TaskEvent {
  final String? status;
  LoadTasks({this.status});
}

class CreateTask extends TaskEvent {
  final String title;
  final String description;
  final String dueDate;
  final String? reminderTime;
  CreateTask({
    required this.title,
    required this.description,
    required this.dueDate,
    this.reminderTime,
  });
}

class UpdateTask extends TaskEvent {
  final String id;
  final String title;
  final String description;
  final String dueDate;
  final String? reminderTime;
  UpdateTask({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.reminderTime,
  });
}

class DeleteTask extends TaskEvent {
  final String id;
  DeleteTask(this.id);
}

class ChangeTaskStatus extends TaskEvent {
  final String id;
  final String status;
  ChangeTaskStatus(this.id, this.status);
}
