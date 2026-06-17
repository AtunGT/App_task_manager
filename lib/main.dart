import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'core/services/notification_service.dart';
import 'core/theme/material_theme.dart';

import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';

import 'features/tasks/data/datasources/task_remote_datasource.dart';
import 'features/tasks/data/repositories/task_repository_impl.dart';
import 'features/tasks/domain/usecases/change_status_usecase.dart';
import 'features/tasks/domain/usecases/create_task_usecase.dart';
import 'features/tasks/domain/usecases/delete_task_usecase.dart';
import 'features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'features/tasks/domain/usecases/update_task_usecase.dart';
import 'features/tasks/presentation/pages/home_page.dart';
import 'features/tasks/presentation/viewmodels/task_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await NotificationService.requestPermissions();

  final prefs = await SharedPreferences.getInstance();
  final apiClient = ApiClient(prefs);

  final authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient);
  final authRepository = AuthRepositoryImpl(authRemoteDataSource, prefs);
  final authViewModel = AuthViewModel(
    loginUsecase: LoginUsecase(authRepository),
    registerUsecase: RegisterUsecase(authRepository),
    prefs: prefs,
  );

  final taskRemoteDataSource = TaskRemoteDataSourceImpl(apiClient);
  final taskRepository = TaskRepositoryImpl(taskRemoteDataSource);
  final taskViewModel = TaskViewModel(
    getTasksUsecase: GetTasksUsecase(taskRepository),
    createTaskUsecase: CreateTaskUsecase(taskRepository),
    updateTaskUsecase: UpdateTaskUsecase(taskRepository),
    deleteTaskUsecase: DeleteTaskUsecase(taskRepository),
    changeStatusUsecase: ChangeStatusUsecase(taskRepository),
  );

  final isLoggedIn = (prefs.getString('token') ?? '').isNotEmpty;

  runApp(MyApp(
    isLoggedIn: isLoggedIn,
    authViewModel: authViewModel,
    taskViewModel: taskViewModel,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final AuthViewModel authViewModel;
  final TaskViewModel taskViewModel;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.authViewModel,
    required this.taskViewModel,
  });

  @override
  Widget build(BuildContext context) {
    final materialTheme = MaterialTheme(ThemeData().textTheme);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>.value(value: authViewModel),
        ChangeNotifierProvider<TaskViewModel>.value(value: taskViewModel),
      ],
      child: MaterialApp(
        title: 'Administrador de Tareas',
        theme: materialTheme.light(),
        darkTheme: materialTheme.dark(),
        debugShowCheckedModeBanner: false,
        locale: const Locale('es'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es'),
          Locale('en'),
        ],
        home: isLoggedIn ? const HomePage() : const LoginPage(),
      ),
    );
  }
}
