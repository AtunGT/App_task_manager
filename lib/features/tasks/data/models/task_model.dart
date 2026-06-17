import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.description,
    required super.dueDate,
    required super.status,
    super.reminderTime,
    required super.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      dueDate: json['due_date'] as String,
      status: json['status'] as String,
      reminderTime: json['reminder_time'] as String?,
      createdAt: json['created_at'] as String,
    );
  }
}
