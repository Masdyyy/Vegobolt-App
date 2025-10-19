import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final savedTheme = await _storage.read(key: 'isDarkMode');
    if (savedTheme != null) {
      _isDarkMode = savedTheme == 'true';
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _storage.write(key: 'isDarkMode', value: _isDarkMode.toString());
    notifyListeners();
  }

  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5DC),
    cardColor: Colors.white,
    primaryColor: const Color(0xFF7AB93F),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF7AB93F),
      secondary: Color(0xFF5A8C2F),
      surface: Colors.white,
      background: Color(0xFFF5F5DC),
    ),
    useMaterial3: true,
  );

  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    cardColor: const Color(0xFF2D2D2D),
    primaryColor: const Color(0xFF7AB93F),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF7AB93F),
      secondary: Color(0xFF5A8C2F),
      surface: Color(0xFF2D2D2D),
      background: Color(0xFF1A1A1A),
    ),
    useMaterial3: true,
  );

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;
}
