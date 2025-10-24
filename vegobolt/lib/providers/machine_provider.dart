import 'package:flutter/material.dart';
import '../utils/colors.dart';

class MachineProvider with ChangeNotifier {
  bool _isActive = true;
  String _location = 'Barangay 171'; // Default location

  bool get isActive => _isActive;
  String get location => _location;

  String get statusText => _isActive ? 'Active' : 'Offline';

  Color get statusColor => _isActive ? AppColors.primaryGreen : Colors.grey;

  void shutdown() {
    _isActive = false;
    notifyListeners();
  }

  void activate() {
    _isActive = true;
    notifyListeners();
  }

  void updateLocation(String newLocation) {
    _location = newLocation;
    notifyListeners();
  }
}

