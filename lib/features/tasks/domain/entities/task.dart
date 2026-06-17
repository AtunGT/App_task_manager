class Task {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String dueDate;
  final String status;
  final String? reminderTime;
  final String createdAt;

  const Task({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    this.reminderTime,
    required this.createdAt,
  });
}
