abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}

class RegisterRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String confirmPassword;

  RegisterRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });
}

class LogoutRequested extends AuthEvent {}
