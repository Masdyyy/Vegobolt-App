import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../utils/api_config.dart';

class InviteCodeService {
  final _secureStorage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> generate({
    int? length,
    int? expiresInDays,
  }) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final uri = Uri.parse(ApiConfig.getUrl('/api/invite-codes'));
      final body = <String, dynamic>{};
      if (length != null) body['length'] = length;
      if (expiresInDays != null) body['expiresInDays'] = expiresInDays;

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Invite code generated',
          'code': responseData['data']?['code'],
          'expiresAt': responseData['data']?['expiresAt'],
        };
      }

      return {
        'success': false,
        'message': responseData['message'] ?? 'Failed to generate invite code',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}
