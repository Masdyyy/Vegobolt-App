import 'package:flutter/material.dart';

class NavigationHelper {
  /// Navigate to a new page with smooth transition
  static void navigateWithoutAnimation(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Smooth easing curve - no visible animation, just smooth feel
          const curve = Curves.easeInOut;
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
          );
          
          return FadeTransition(
            opacity: Tween<double>(begin: 0.98, end: 1.0).animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );
  }
}
