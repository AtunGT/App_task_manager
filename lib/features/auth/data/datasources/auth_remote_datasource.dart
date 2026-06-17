import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
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
  final DioClient client;
  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<({String token, UserModel user})> login(String email, String password) async {
    final response = await client.dio.post(ApiConstants.login, data: {
      'email': email,
      'password': password,
    });
    return (
      token: response.data['token'] as String,
      user: UserModel.fromJson(response.data['user'] as Map<String, dynamic>),
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
    final response = await client.dio.post(ApiConstants.register, data: {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
    });
    return (
      token: response.data['token'] as String,
      user: UserModel.fromJson(response.data['user'] as Map<String, dynamic>),
    );
  }
}
