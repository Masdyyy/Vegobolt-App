import 'package:flutter/material.dart';
import '../utils/colors.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: isDark ? AppColors.darkCardBackground : Colors.white,
      selectedItemColor: const Color(0xFF7BA23F),
      unselectedItemColor: isDark ? AppColors.darkTextSecondary : Colors.grey,
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.oil_barrel), label: "Tanks"),
        BottomNavigationBarItem(icon: Icon(Icons.warning), label: "Alerts"),
        BottomNavigationBarItem(icon: Icon(Icons.build), label: "Maintenance"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }
}
