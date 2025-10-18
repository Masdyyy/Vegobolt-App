import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _secureStorage = const FlutterSecureStorage();
  final _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRemembered(); // load email & remember flag (if any)
  }

  Future<void> _loadRemembered() async {
    try {
      final savedEmail = await _secureStorage.read(key: 'remembered_email');
      final rememberFlag = await _secureStorage.read(key: 'remember_me');
      if (savedEmail != null) {
        // only update UI if mounted
        if (mounted) {
          setState(() {
            _emailController.text = savedEmail;
            _rememberMe = (rememberFlag == 'true');
          });
        }
      } else {
        if (mounted) {
          setState(() => _rememberMe = false);
        }
      }
    } catch (e) {
      // ignore storage errors but you may log them during development
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _setRememberedEmail(String? email, bool remember) async {
    try {
      if (remember && email != null && email.isNotEmpty) {
        await _secureStorage.write(key: 'remembered_email', value: email);
        await _secureStorage.write(key: 'remember_me', value: 'true');
      } else {
        await _secureStorage.delete(key: 'remembered_email');
        await _secureStorage.delete(key: 'remember_me');
      }
    } catch (e) {
      // ignore for now; optionally show an error or log
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    try {
      // Call backend API to login
      final result = await _authService.login(email, password);

      if (!mounted) return;

      if (result['success'] == true) {
        // Successful login
        // Persist remember-me preference (store or delete email)
        await _setRememberedEmail(email, _rememberMe);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Login successful'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear sensitive fields
        _passwordController.clear();

        // Navigate to dashboard
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        // Login failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate Google login process
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Navigate to dashboard
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Light cream background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // stroked (behind)
                      Transform.rotate(
                        angle: 0,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'VEGO',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                  // stroke paint:
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 3.2 // increase to make heavier
                                    ..color = const Color(0xFF5A6B47),
                                  letterSpacing: -1.8,
                                ),
                              ),
                              TextSpan(
                                text: 'BOLT',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 3.2
                                    ..color = const Color(0xFFFFD700),
                                  letterSpacing: -1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // filled (front)
                      Transform.rotate(
                        angle: 0,
                        child: RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'VEGO',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF5A6B47),
                                  letterSpacing: -1.8,
                                ),
                              ),
                              TextSpan(
                                text: 'BOLT',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFFFD700),
                                  letterSpacing: -1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),

                // Log in Title
                const Text(
                  'Log in',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A6B47), // Dark olive green
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Enter your email and password',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),

                const SizedBox(height: 40),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email Address',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Colors.grey[700],
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[400]!,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[400]!,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF5A6B47),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Colors.grey[700],
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey[700],
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[400]!,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[400]!,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF5A6B47),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Remember me and Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) async {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                            // If user unchecks, remove stored email immediately.
                            if (!(_rememberMe)) {
                              await _setRememberedEmail(null, false);
                            } else {
                              // if user checks, save current email immediately (if any)
                              final currentEmail = _emailController.text.trim().toLowerCase();
                              await _setRememberedEmail(currentEmail.isNotEmpty ? currentEmail : null, true);
                            }
                          },
                          activeColor: const Color(0xFF5A6B47),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Text(
                          'Remember me',
                          style: TextStyle(
                            color: Color(0xFF5A6B47),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot');
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFF8B5A96), // Purple color
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Log in Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700), // Golden yellow
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Log in',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),

                // Or separator
                Row(
                  children: [
                    Expanded(
                      child: Container(height: 1, color: Colors.grey[300]),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ),
                    Expanded(
                      child: Container(height: 1, color: Colors.grey[300]),
                    ),
                  ],
                ),

                const SizedBox(height: 20), // reduced spacing here

                // Google Login Button
                SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _handleGoogleLogin,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF5A6B47),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://developers.google.com/identity/images/g-logo.png',
                              ),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Log in with google',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16), // smaller gap to the sign-up row

                // Sign Up Link (moved up a bit and given a small bottom padding)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Color(0xFF5A6B47), // Dark olive green
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}