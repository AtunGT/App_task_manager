import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository repository;
  RegisterUsecase(this.repository);

  Future<({String token, User user})> call({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return repository.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
  }
}
