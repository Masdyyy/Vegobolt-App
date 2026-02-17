import 'dart:convert';
import 'package:http/http.dart' as http;

class TankService {
  // 👇 Replace this with your actual computer’s local IP
  static const String baseUrl = "http://192.168.87.224:3000";

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

  // ========== PUMP/TAPO PLUG CONTROL ==========

  /// Turn pump/plug ON
  static Future<Map<String, dynamic>> turnPumpOn() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/pump/on'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to turn pump on");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  /// Turn pump/plug OFF
  static Future<Map<String, dynamic>> turnPumpOff() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/pump/off'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to turn pump off");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  /// Toggle pump/plug state
  static Future<Map<String, dynamic>> togglePump() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/pump/toggle'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to toggle pump");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  /// Get current pump/plug status
  static Future<Map<String, dynamic>> getPumpStatus() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/pump/status'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to fetch pump status");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  /// Control pump with command (ON/OFF/TOGGLE)
  static Future<Map<String, dynamic>> controlPump(String command) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/pump/control'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"command": command}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to control pump");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  /// Get energy usage (if supported by device)
  static Future<Map<String, dynamic>> getEnergyUsage() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/pump/energy'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to fetch energy usage");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
