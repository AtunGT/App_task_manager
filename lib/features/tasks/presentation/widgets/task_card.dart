import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/task.dart';
import '../viewmodels/task_viewmodel.dart';
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

  Future<void> _changeStatus(BuildContext context, String newStatus) async {
    final vm = context.read<TaskViewModel>();
    final ok = await vm.changeStatus(task.id, newStatus);
    if (ok) await vm.loadTasks(currentStatus);
  }

  void _delete(BuildContext context) {
    final vm = context.read<TaskViewModel>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: const Text('¿Estás seguro de eliminar esta tarea?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final ok = await vm.deleteTask(task.id);
              if (ok) await vm.loadTasks(currentStatus);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _edit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormPage(task: task, currentStatus: currentStatus),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = _statusColor(task.status, cs);
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 6, color: accent),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 16, 16),
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
                          _edit(context);
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
                        color: accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accent, width: 1),
                      ),
                      child: Text(
                        _statusLabel(task.status),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
