import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

enum AuthStatus { initial, loading, success, registered, failure, loggedOut }

class AuthViewModel extends ChangeNotifier {
  final LoginUsecase loginUsecase;
  final RegisterUsecase registerUsecase;
  final SharedPreferences prefs;

  AuthViewModel({
    required this.loginUsecase,
    required this.registerUsecase,
    required this.prefs,
  });

  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;

  User? _user;
  User? get user => _user;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == AuthStatus.loading;

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await loginUsecase(email, password);
      _user = result.user;
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Credenciales inválidas';
      _status = AuthStatus.failure;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await registerUsecase(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      _status = AuthStatus.registered;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.failure;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await prefs.clear();
    _user = null;
    _status = AuthStatus.loggedOut;
    notifyListeners();
  }
}
