import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';

class TaskFormPage extends StatefulWidget {
  final Task? task;
  final String currentStatus;

  const TaskFormPage({super.key, this.task, required this.currentStatus});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task?.title ?? '');
    _descCtrl = TextEditingController(text: widget.task?.description ?? '');
    if (widget.task != null) {
      final parts = widget.task!.dueDate.split('-');
      _selectedDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      if (widget.task!.reminderTime != null) {
        final timeParts = widget.task!.reminderTime!.split(':');
        _selectedTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una fecha')),
      );
      return;
    }

    final dueDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final reminderTime = _selectedTime != null
        ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00'
        : null;

    setState(() => _loading = true);

    if (widget.task == null) {
      context.read<TaskBloc>().add(CreateTask(
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            dueDate: dueDate,
            reminderTime: reminderTime,
          ));
    } else {
      context.read<TaskBloc>().add(UpdateTask(
            id: widget.task!.id,
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            dueDate: dueDate,
            reminderTime: reminderTime,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskOperationSuccess) {
          context.read<TaskBloc>().add(LoadTasks(status: widget.currentStatus));
          Navigator.pop(context);
        } else if (state is TaskFailure) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Editar tarea' : 'Nueva tarea'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'El título es requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _selectedDate == null
                      ? 'Seleccionar fecha'
                      : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                ),
                onTap: _pickDate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.alarm),
                title: Text(
                  _selectedTime == null
                      ? 'Agregar recordatorio (opcional)'
                      : 'Recordatorio: ${_selectedTime!.format(context)}',
                ),
                trailing: _selectedTime != null
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _selectedTime = null),
                      )
                    : null,
                onTap: _pickTime,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEditing ? 'Guardar cambios' : 'Crear tarea'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
