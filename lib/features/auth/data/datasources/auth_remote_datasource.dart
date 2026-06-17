import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<({String token, UserModel user})> login(String email, String password);
  Future<({String token, UserModel user})> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient client;
  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<({String token, UserModel user})> login(String email, String password) async {
    final data = await client.post(ApiConstants.login, body: {
      'email': email,
      'password': password,
    });
    return (
      token: data['token'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  @override
  Future<({String token, UserModel user})> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final data = await client.post(ApiConstants.register, body: {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
    });
    return (
      token: data['token'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }
}
