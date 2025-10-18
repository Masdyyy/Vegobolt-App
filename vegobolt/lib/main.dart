import 'package:flutter/material.dart';

// ✅ Import all your pages
import 'Pages/alerts.dart';
import 'Pages/dashboard.dart';
import 'Pages/login.dart';
import 'Pages/machine.dart';
import 'Pages/maintenance.dart';
import 'Pages/settings.dart';
import 'Pages/forgetpassword.dart';
import 'Pages/signup.dart';
import 'Pages/HelpSupport.dart';
import 'Pages/AccountSettings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var routes = {
      '/dashboard': (context) => const DashboardPage(),
      '/login': (context) => const LoginPage(),
      '/forgot': (context) => const ForgotPasswordPage(),
      '/signup': (context) => const SignupPage(),
      '/machine': (context) => const MachinePage(),
      '/alerts': (context) => const AlertsPage(),
      '/maintenance': (context) => const MaintenancePage(),
      '/settings': (context) => const SettingsPage(),
      '/helpsupport': (context) => const HelpSupportPage(),
      '/accountsettings': (context) => const AccountSettingsPage(),
    };
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vegobolt Mobile App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      // 👇 Choose your starting page here
      home: const LoginPage(),

      // To start with login page instead, change above to: home: const LoginPage(),
      routes: routes,
    );
  }
}
