import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../utils/api_config.dart';

class MaintenanceService {
  final AuthService _auth = AuthService();

  Future<List<Map<String, dynamic>>> list({String? status}) async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl(ApiConfig.maintenanceList)).replace(queryParameters: status != null ? {'status': status} : null);
      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});
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

  Future<Map<String, dynamic>?> create(Map<String, dynamic> data) async {
    try {
      final token = await _auth.getToken();
      final uri = Uri.parse(ApiConfig.getUrl(ApiConfig.maintenanceBase));
      final body = {
        'title': data['title'],
        'machineId': data['machineId'],
        'location': data['location'],
        'priority': data['priority'],
        // Ensure date is sent in UTC ISO format to avoid timezone shifts on server
        'scheduledDate': data['scheduledDate'] != null
            ? (data['scheduledDate'] is DateTime
                ? data['scheduledDate'].toUtc().toIso8601String()
                : data['scheduledDate'])
            : null,
      };
      final response = await http.post(uri,
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token'
          },
          body: jsonEncode(body));
      final bodyJson = jsonDecode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) && bodyJson['success'] == true) {
        return Map<String, dynamic>.from(bodyJson['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> update(String id, Map<String, dynamic> updates) async {
    try {
      final token = await _auth.getToken();
      final uri = Uri.parse(ApiConfig.getUrl('${ApiConfig.maintenanceBase}/$id'));
      if (updates['scheduledDate'] is DateTime) updates['scheduledDate'] = updates['scheduledDate'].toUtc().toIso8601String();
      final response = await http.put(uri,
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token'
          },
          body: jsonEncode(updates));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      final token = await _auth.getToken();
      final uri = Uri.parse(ApiConfig.getUrl('${ApiConfig.maintenanceBase}/$id'));
      final response = await http.delete(uri, headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token'
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> resolve(String id) async {
    try {
      final token = await _auth.getToken();
      final uri = Uri.parse(ApiConfig.getUrl('${ApiConfig.maintenanceBase}/$id/resolve'));
      final response = await http.post(uri, headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token'
      });
      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body['success'] == true) return Map<String, dynamic>.from(body['data']);
      return null;
    } catch (e) {
      return null;
    }
  }
}
