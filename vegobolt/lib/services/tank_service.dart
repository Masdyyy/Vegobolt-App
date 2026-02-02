import 'dart:convert';
import 'package:http/http.dart' as http;

class TankService {
  // 👇 Replace this with your actual computer’s local IP
  static const String baseUrl = "http://10.11.54.224:3000";

  /// Get current tank data (from Node backend or ESP32)
  static Future<Map<String, dynamic>> getTankStatus() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/tank/status'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to fetch tank status");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  /// Send manual update (optional, for testing)
  static Future<Map<String, dynamic>> updateTankStatus(String status) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/tank/update'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"status": status}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to update tank status");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
