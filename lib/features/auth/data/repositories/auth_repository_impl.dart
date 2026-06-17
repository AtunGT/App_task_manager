import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPreferences prefs;

  AuthRepositoryImpl(this.remoteDataSource, this.prefs);

  @override
  Future<({String token, User user})> login(String email, String password) async {
    final result = await remoteDataSource.login(email, password);
    await prefs.setString('token', result.token);
    await prefs.setString('user_name', '${result.user.firstName} ${result.user.lastName}');
    return result;
  }

  @override
  Future<({String token, User user})> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final result = await remoteDataSource.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    return result;
  }
}
