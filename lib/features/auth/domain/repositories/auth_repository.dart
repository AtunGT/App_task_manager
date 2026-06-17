import '../entities/user.dart';

abstract class AuthRepository {
  Future<({String token, User user})> login(String email, String password);
  Future<({String token, User user})> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  });
}
