import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/usecases/change_status_usecase.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUsecase getTasks;
  final CreateTaskUsecase createTask;
  final UpdateTaskUsecase updateTask;
  final DeleteTaskUsecase deleteTask;
  final ChangeStatusUsecase changeStatus;

  TaskBloc({
    required this.getTasks,
    required this.createTask,
    required this.updateTask,
    required this.deleteTask,
    required this.changeStatus,
  }) : super(TaskInitial()) {
    on<LoadTasks>(_onLoad);
    on<CreateTask>(_onCreate);
    on<UpdateTask>(_onUpdate);
    on<DeleteTask>(_onDelete);
    on<ChangeTaskStatus>(_onChangeStatus);
  }

  Future<void> _onLoad(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks = await getTasks(status: event.status);
      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TaskFailure(e.toString()));
    }
  }

  Future<void> _onCreate(CreateTask event, Emitter<TaskState> emit) async {
    try {
      final task = await createTask(
        title: event.title,
        description: event.description,
        dueDate: event.dueDate,
        reminderTime: event.reminderTime,
      );
      if (task.reminderTime != null) {
        final parts = task.reminderTime!.split(':');
        final dateParts = task.dueDate.split('-');
        final scheduled = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
        await NotificationService.schedule(
          taskId: task.id,
          title: task.title,
          scheduledDate: scheduled,
        );
      }
      emit(TaskOperationSuccess());
    } catch (e) {
      emit(TaskFailure(e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      final task = await updateTask(
        id: event.id,
        title: event.title,
        description: event.description,
        dueDate: event.dueDate,
        reminderTime: event.reminderTime,
      );
      await NotificationService.cancel(task.id);
      if (task.reminderTime != null) {
        final parts = task.reminderTime!.split(':');
        final dateParts = task.dueDate.split('-');
        final scheduled = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
        await NotificationService.schedule(
          taskId: task.id,
          title: task.title,
          scheduledDate: scheduled,
        );
      }
      emit(TaskOperationSuccess());
    } catch (e) {
      emit(TaskFailure(e.toString()));
    }
  }

  Future<void> _onDelete(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await deleteTask(event.id);
      await NotificationService.cancel(event.id);
      emit(TaskOperationSuccess());
    } catch (e) {
      emit(TaskFailure(e.toString()));
    }
  }

  Future<void> _onChangeStatus(ChangeTaskStatus event, Emitter<TaskState> emit) async {
    try {
      await changeStatus(event.id, event.status);
      emit(TaskOperationSuccess());
    } catch (e) {
      emit(TaskFailure(e.toString()));
    }
  }
}
