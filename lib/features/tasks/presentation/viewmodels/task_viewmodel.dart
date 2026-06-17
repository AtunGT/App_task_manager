import 'package:flutter/foundation.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/change_status_usecase.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';

enum TaskViewState { initial, loading, loaded, failure }

class TaskViewModel extends ChangeNotifier {
  final GetTasksUsecase getTasksUsecase;
  final CreateTaskUsecase createTaskUsecase;
  final UpdateTaskUsecase updateTaskUsecase;
  final DeleteTaskUsecase deleteTaskUsecase;
  final ChangeStatusUsecase changeStatusUsecase;

  TaskViewModel({
    required this.getTasksUsecase,
    required this.createTaskUsecase,
    required this.updateTaskUsecase,
    required this.deleteTaskUsecase,
    required this.changeStatusUsecase,
  });

  TaskViewState _state = TaskViewState.initial;
  TaskViewState get state => _state;

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadTasks(String status) async {
    _state = TaskViewState.loading;
    notifyListeners();
    try {
      _tasks = await getTasksUsecase(status: status);
      _state = TaskViewState.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = TaskViewState.failure;
    }
    notifyListeners();
  }

  Future<bool> createTask({
    required String title,
    required String description,
    required String dueDate,
    String? reminderTime,
  }) async {
    try {
      final task = await createTaskUsecase(
        title: title,
        description: description,
        dueDate: dueDate,
        reminderTime: reminderTime,
      );
      await _scheduleReminder(task);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask({
    required String id,
    required String title,
    required String description,
    required String dueDate,
    String? reminderTime,
  }) async {
    try {
      final task = await updateTaskUsecase(
        id: id,
        title: title,
        description: description,
        dueDate: dueDate,
        reminderTime: reminderTime,
      );
      await NotificationService.cancel(task.id);
      await _scheduleReminder(task);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(String id) async {
    try {
      await deleteTaskUsecase(id);
      await NotificationService.cancel(id);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> changeStatus(String id, String status) async {
    try {
      await changeStatusUsecase(id, status);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> _scheduleReminder(Task task) async {
    if (task.reminderTime == null) return;
    final timeParts = task.reminderTime!.split(':');
    final dateParts = task.dueDate.split('-');
    final scheduled = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
    await NotificationService.schedule(
      taskId: task.id,
      title: task.title,
      scheduledDate: scheduled,
    );
  }
}
