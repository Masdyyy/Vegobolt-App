import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ✅ Import all your pages
import 'Pages/alerts.dart';
import 'Pages/dashboard.dart';
import 'Pages/login.dart';
import 'Pages/machine.dart';
import 'Pages/maintenance.dart';
import 'Pages/settings.dart';
import 'Pages/forgetpassword.dart';
import 'Pages/ResetPassword.dart';
import 'Pages/signup.dart';
import 'Pages/HelpSupport.dart';
import 'Pages/AccountSettings.dart';
import 'utils/theme_provider.dart';
import 'providers/machine_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MachineProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

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
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // 👇 Choose your starting page here
      home: const LoginPage(),

      // To start with login page instead, change above to: home: const LoginPage(),
      routes: routes,

      // Handle dynamic routes like reset-password with token
      onGenerateRoute: (settings) {
        if (settings.name == '/reset-password') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => ResetPasswordPage(token: args?['token']),
          );
        }
        return null;
      },
    );
  }
}
