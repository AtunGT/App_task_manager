import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../viewmodels/task_viewmodel.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTasks());
  }

  String get _currentStatus => _statuses[_tabController.index];

  void _loadTasks() {
    context.read<TaskViewModel>().loadTasks(_currentStatus);
  }

  Future<void> _logout() async {
    final navigator = Navigator.of(context);
    await context.read<AuthViewModel>().logout();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
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
      body: Consumer<TaskViewModel>(
        builder: (context, vm, _) {
          if (vm.state == TaskViewState.loading ||
              vm.state == TaskViewState.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.state == TaskViewState.failure) {
            return _ErrorView(
              message: vm.errorMessage ?? 'Ocurrió un error',
              onRetry: _loadTasks,
            );
          }
          if (vm.tasks.isEmpty) {
            return _EmptyView(onRefresh: () => vm.loadTasks(_currentStatus));
          }
          return RefreshIndicator(
            onRefresh: () => vm.loadTasks(_currentStatus),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _ListHeader(
                    label: _labels[_tabController.index],
                    count: vm.tasks.length,
                  ),
                ),
                SliverList.builder(
                  itemCount: vm.tasks.length,
                  itemBuilder: (_, i) => TaskCard(
                    task: vm.tasks[i],
                    currentStatus: _currentStatus,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskFormPage(currentStatus: _currentStatus),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  final String label;
  final int count;

  const _ListHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Stack(
        children: [
          Container(
            height: 84,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [cs.primaryContainer, cs.tertiaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: cs.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '$count tarea${count == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cs.onPrimaryContainer,
                            ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: cs.surface.withValues(alpha: 0.6),
                    child: Text(
                      '$count',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptyView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
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
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: cs.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
