import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../pages/task_form_page.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final String currentStatus;

  const TaskCard({super.key, required this.task, required this.currentStatus});

  String _statusLabel(String status) {
    switch (status) {
      case 'todo':
        return 'Por hacer';
      case 'in_progress':
        return 'En proceso';
      case 'done':
        return 'Terminado';
      default:
        return status;
    }
  }

  Color _statusColor(String status, ColorScheme cs) {
    switch (status) {
      case 'todo':
        return cs.tertiary;
      case 'in_progress':
        return cs.primary;
      case 'done':
        return cs.secondary;
      default:
        return cs.outline;
    }
  }

  void _changeStatus(BuildContext context, String newStatus) {
    final bloc = context.read<TaskBloc>();
    bloc.add(ChangeTaskStatus(task.id, newStatus));
    Future.delayed(const Duration(milliseconds: 300), () {
      bloc.add(LoadTasks(status: currentStatus));
    });
  }

  void _delete(BuildContext context) {
    final bloc = context.read<TaskBloc>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: const Text('¿Estás seguro de eliminar esta tarea?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              bloc.add(DeleteTask(task.id));
              Future.delayed(const Duration(milliseconds: 300), () {
                bloc.add(LoadTasks(status: currentStatus));
              });
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<TaskBloc>(),
                            child: TaskFormPage(
                              task: task,
                              currentStatus: currentStatus,
                            ),
                          ),
                        ),
                      );
                    } else if (value == 'delete') {
                      _delete(context);
                    } else {
                      _changeStatus(context, value);
                    }
                  },
                  itemBuilder: (_) => [
                    if (task.status != 'todo')
                      const PopupMenuItem(
                        value: 'todo',
                        child: Text('Por hacer'),
                      ),
                    if (task.status != 'in_progress')
                      const PopupMenuItem(
                        value: 'in_progress',
                        child: Text('En proceso'),
                      ),
                    if (task.status != 'done')
                      const PopupMenuItem(
                        value: 'done',
                        child: Text('Terminado'),
                      ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Editar'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Eliminar'),
                    ),
                  ],
                ),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                task.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  task.dueDate,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
                if (task.reminderTime != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.alarm, size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    task.reminderTime!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _statusColor(task.status, cs).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _statusColor(task.status, cs),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _statusLabel(task.status),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _statusColor(task.status, cs),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
