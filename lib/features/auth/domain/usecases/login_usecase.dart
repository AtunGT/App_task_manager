import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository repository;
  LoginUsecase(this.repository);

  Future<({String token, User user})> call(String email, String password) {
    return repository.login(email, password);
  }
}
