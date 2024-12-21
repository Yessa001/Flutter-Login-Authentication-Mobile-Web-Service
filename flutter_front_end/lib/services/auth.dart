import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const secureStorage = FlutterSecureStorage();

const String baseUrl = 'http://192.168.1.10:8001';

// Login Users
Future<void> login(String email, String password) async {
  final url = Uri.parse('$baseUrl/auth/login');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final accessToken = data['token']['access_token'];

    await secureStorage.write(key: 'access_token', value: accessToken);
    print('Access token successfully stored!');
  } else {
    final error = json.decode(response.body);
    throw Exception('Login Failed: ${error['message'] ?? 'Server error'}');
  }
}

// Fetch Data
Future<Map<String, dynamic>> fetchProtectedData() async {
  final url = Uri.parse('$baseUrl/me');
  final accessToken = await secureStorage.read(key: 'access_token');

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data; 
  } else if (response.statusCode == 401) {
    throw Exception('Invalid or expired access token. Please log in again.');
  } else {
    final error = json.decode(response.body);
    throw Exception('Error: ${error['message'] ?? 'Server error'}');
  }
}

// Delete Access Token
Future<void> logout() async {
  await secureStorage.delete(key: 'access_token');
  print('Access token successfully deleted.');
}
Future<bool> isTokenAvailable() async {
  final token = await secureStorage.read(key: 'access_token');
  return token != null;
}
