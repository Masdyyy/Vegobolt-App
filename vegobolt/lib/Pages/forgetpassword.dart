import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) {
      return;
    }

    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Password reset link sent to ${_emailController.text}'),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5DC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF5A6B47)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
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
                const SizedBox(height: 32),
                const Text(
                  'Forgot Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF5A6B47),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your email address to get a\nreset link',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 20),
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
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: const Color(0xFF5A6B47).withValues(alpha: 0.6),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: const Color(0xFF5A6B47).withValues(alpha: 0.6),
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(
                        color: Color(0xFF5A6B47),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter your email';
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(value))
                      return 'Please enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendResetLink,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
