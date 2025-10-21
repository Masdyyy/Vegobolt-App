import 'package:flutter/material.dart';
import '../utils/colors.dart';

class MachineProvider with ChangeNotifier {
  bool _isActive = true;

  bool get isActive => _isActive;

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
}

