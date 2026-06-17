import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/dio_client.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/tasks/data/datasources/task_remote_datasource.dart';
import 'features/tasks/data/repositories/task_repository_impl.dart';
import 'features/tasks/domain/repositories/task_repository.dart';
import 'features/tasks/domain/usecases/change_status_usecase.dart';
import 'features/tasks/domain/usecases/create_task_usecase.dart';
import 'features/tasks/domain/usecases/delete_task_usecase.dart';
import 'features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'features/tasks/domain/usecases/update_task_usecase.dart';
import 'features/tasks/presentation/bloc/task_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  sl.registerLazySingleton<DioClient>(() => DioClient(sl()));

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => RegisterUsecase(sl()));
  sl.registerFactory(() => AuthBloc(login: sl(), register: sl(), prefs: sl()));

  sl.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetTasksUsecase(sl()));
  sl.registerLazySingleton(() => CreateTaskUsecase(sl()));
  sl.registerLazySingleton(() => UpdateTaskUsecase(sl()));
  sl.registerLazySingleton(() => DeleteTaskUsecase(sl()));
  sl.registerLazySingleton(() => ChangeStatusUsecase(sl()));
  sl.registerFactory(() => TaskBloc(
        getTasks: sl(),
        createTask: sl(),
        updateTask: sl(),
        deleteTask: sl(),
        changeStatus: sl(),
      ));
}
