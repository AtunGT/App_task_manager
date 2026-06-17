import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/notification_service.dart';
import 'core/theme/material_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/tasks/presentation/bloc/task_bloc.dart';
import 'features/tasks/presentation/pages/home_page.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await di.init();
  final prefs = di.sl<SharedPreferences>();
  final isLoggedIn = (prefs.getString('token') ?? '').isNotEmpty;
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final materialTheme = MaterialTheme(ThemeData().textTheme);
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<TaskBloc>()),
      ],
      child: MaterialApp(
        title: 'Administrador de Tareas',
        theme: materialTheme.light(),
        darkTheme: materialTheme.dark(),
        debugShowCheckedModeBanner: false,
        home: isLoggedIn ? const HomePage() : const LoginPage(),
      ),
    );
  }
}
