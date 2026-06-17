import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiClient {
  final http.Client _client;
  final SharedPreferences _prefs;

  ApiClient(this._prefs, {http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _headers() {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final token = _prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, dynamic>? queryParameters]) {
    final base = Uri.parse('${ApiConstants.baseUrl}$path');
    if (queryParameters == null || queryParameters.isEmpty) return base;
    return base.replace(
      queryParameters:
          queryParameters.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    final response = await _client.get(_uri(path, queryParameters), headers: _headers());
    return _process(response);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final response = await _client.post(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    return _process(response);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final response = await _client.put(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    return _process(response);
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    final response = await _client.patch(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    return _process(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await _client.delete(_uri(path), headers: _headers());
    return _process(response);
  }

  dynamic _process(http.Response response) {
    final dynamic data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    final message = (data is Map && data['message'] != null)
        ? data['message'].toString()
        : 'Error ${response.statusCode}';
    throw Exception(message);
  }
}
