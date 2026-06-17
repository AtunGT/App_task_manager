import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/task_card.dart';
import 'task_form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<String> _statuses = ['todo', 'in_progress', 'done'];
  final List<String> _labels = ['Por hacer', 'En proceso', 'Terminado'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadTasks();
      }
    });
    _loadTasks();
  }

  void _loadTasks() {
    context
        .read<TaskBloc>()
        .add(LoadTasks(status: _statuses[_tabController.index]));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (_) => false,
          );
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _labels.map((l) => Tab(text: l)).toList(),
          labelColor: cs.primary,
          unselectedLabelColor: cs.onSurfaceVariant,
          indicatorColor: cs.primary,
        ),
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TasksLoaded) {
            if (state.tasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 64,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay tareas',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => _loadTasks(),
              child: ListView.builder(
                itemCount: state.tasks.length,
                itemBuilder: (_, i) => TaskCard(
                  task: state.tasks[i],
                  currentStatus: _statuses[_tabController.index],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<TaskBloc>(),
                child: TaskFormPage(
                  currentStatus: _statuses[_tabController.index],
                ),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      ),
    );
  }
}
