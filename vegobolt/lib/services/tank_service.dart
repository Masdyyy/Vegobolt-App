import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

class TankService {
  // ✅ Use centralized API config (automatically switches between production and local)
  static String get baseUrl => ApiConfig.baseUrl;

  // ✅ Add timeout duration
  static const Duration timeoutDuration = Duration(seconds: 10);

  /// Get current tank data (from Node backend or ESP32)
  static Future<Map<String, dynamic>> getTankStatus() async {
    try {
      print('🔍 Fetching tank status from: $baseUrl/api/tank/status');

      final response = await http
          .get(Uri.parse('$baseUrl/api/tank/status'))
          .timeout(timeoutDuration);

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Tank data received: $data');
        return data;
      } else {
        print('❌ Server error: ${response.statusCode} - ${response.body}');
        throw Exception("Server returned ${response.statusCode}");
      }
    } on TimeoutException catch (e) {
      print('⏱️ Request timeout after ${timeoutDuration.inSeconds}s');
      print('   Server URL: $baseUrl');
      throw Exception("Connection timeout - check if backend is running");
    } on http.ClientException catch (e) {
      print('🌐 Network error: $e');
      print('   Server URL: $baseUrl');
      throw Exception("Cannot connect to server");
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception("Error fetching tank data: $e");
    }
  }

  /// Send manual update (optional, for testing)
  static Future<Map<String, dynamic>> updateTankStatus(String status) async {
    try {
      print('📤 Sending tank update to: $baseUrl/api/tank/update');

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/tank/update'),
            headers: {"Content-Type": "application/json"},
            body: json.encode({"status": status}),
          )
          .timeout(timeoutDuration);

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Update successful: $data');
        return data;
      } else {
        print('❌ Server error: ${response.statusCode} - ${response.body}');
        throw Exception("Server returned ${response.statusCode}");
      }
    } on TimeoutException catch (e) {
      print('⏱️ Request timeout after ${timeoutDuration.inSeconds}s');
      throw Exception("Connection timeout");
    } on http.ClientException catch (e) {
      print('🌐 Network error: $e');
      throw Exception("Cannot connect to server");
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception("Error updating tank status: $e");
    }
  }

  /// Test connection to backend
  static Future<bool> testConnection() async {
    try {
      print('🧪 Testing connection to: $baseUrl/health');

      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(Duration(seconds: 5));

      print('📡 Health check response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Connection test failed: $e');
      return false;
    }
  }
}
