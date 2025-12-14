import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/api_config.dart';

class AdminUserService {
  final _secureStorage = const FlutterSecureStorage();

  Future<List<Map<String, dynamic>>> listUsers() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final uri = Uri.parse(ApiConfig.getUrl('/api/users'));
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token'
      });
      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body['success'] == true) {
        final List items = body['data'] ?? [];
        return items.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> adminDeleteUser(String id) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final uri = Uri.parse(ApiConfig.getUrl('/api/users/$id'));
      final response = await http.delete(uri, headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token'
      });
      final body = jsonDecode(response.body);
      return response.statusCode == 200 && body['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setActive(String id, bool active) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final uri = Uri.parse(ApiConfig.getUrl('/api/users/$id/active'));
      final response = await http.put(uri,
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token'
          },
          body: jsonEncode({'active': active}));
      final body = jsonDecode(response.body);
      return response.statusCode == 200 && body['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
