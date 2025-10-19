# Flutter App Integration Guide for Email Verification

## Overview
This guide shows how to integrate the email verification feature into your Flutter app.

## Backend Response Changes

### 1. Registration Response (Modified)

```dart
// POST /api/auth/register
{
  "success": true,
  "message": "User registered successfully. Please check your email to verify your account.",
  "data": {
    "user": {
      "id": "...",
      "email": "user@example.com",
      "displayName": "John Doe",
      "isEmailVerified": false,
      "createdAt": "2025-10-19T12:00:00.000Z"
    },
    "token": "eyJhbGc...",
    "requiresEmailVerification": true  // NEW FLAG
  }
}
```

### 2. Login Response (Modified - Unverified)

```dart
// POST /api/auth/login (when email not verified)
{
  "success": false,
  "message": "Please verify your email before logging in. Check your inbox for the verification link.",
  "requiresEmailVerification": true  // NEW FLAG
}
```

## Recommended UI/UX Flow

### Registration Flow

```
1. User fills registration form
   ↓
2. Submit to /api/auth/register
   ↓
3. If success && requiresEmailVerification:
   ↓
4. Show "Email Verification Required" screen
   - "We've sent a verification link to your email"
   - Email address display
   - "Didn't receive email?" button → Resend
   - "Open Email App" button (optional)
```

### Login Flow

```
1. User enters credentials
   ↓
2. Submit to /api/auth/login
   ↓
3. If error && requiresEmailVerification:
   ↓
4. Show "Email Not Verified" dialog
   - Message explaining verification needed
   - "Resend Verification Email" button
   - "OK" button to dismiss
```

## Code Examples

### 1. Update Auth Service

```dart
// lib/services/auth_service.dart

class AuthService {
  // ... existing code ...

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'displayName': displayName,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success']) {
        // Check if email verification is required
        final requiresVerification = 
            data['data']['requiresEmailVerification'] ?? false;
        
        return {
          'success': true,
          'message': data['message'],
          'requiresEmailVerification': requiresVerification,
          'user': data['data']['user'],
          'token': data['data']['token'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        // Login successful
        return {
          'success': true,
          'message': data['message'],
          'user': data['data']['user'],
          'token': data['data']['token'],
        };
      } else {
        // Login failed - check if it's due to email verification
        final requiresVerification = 
            data['requiresEmailVerification'] ?? false;
        
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
          'requiresEmailVerification': requiresVerification,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> resendVerificationEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/resend-verification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Failed to resend email',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}
```

### 2. Update Signup Page

```dart
// lib/Pages/Signup.dart

class _SignupState extends State<Signup> {
  // ... existing code ...

  void _handleSignup() async {
    // ... validation code ...

    setState(() => _isLoading = true);

    final result = await _authService.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _displayNameController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      if (result['requiresEmailVerification'] == true) {
        // Show email verification screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(
              email: _emailController.text.trim(),
            ),
          ),
        );
      } else {
        // Navigate to home (old flow, if verification not required)
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }
}
```

### 3. Update Login Page

```dart
// lib/Pages/Login.dart

class _LoginState extends State<Login> {
  // ... existing code ...

  void _handleLogin() async {
    // ... validation code ...

    setState(() => _isLoading = true);

    final result = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      // Save token and navigate to home
      await _saveToken(result['token']);
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Check if error is due to email verification
      if (result['requiresEmailVerification'] == true) {
        _showEmailVerificationDialog();
      } else {
        // Show general error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    }
  }

  void _showEmailVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Email Not Verified'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.email_outlined, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Please verify your email address before logging in. '
              'Check your inbox for the verification link.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resendVerificationEmail();
            },
            child: Text('Resend Email'),
          ),
        ],
      ),
    );
  }

  void _resendVerificationEmail() async {
    final result = await _authService.resendVerificationEmail(
      _emailController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: result['success'] ? Colors.green : Colors.red,
      ),
    );
  }
}
```

### 4. Create Email Verification Screen

```dart
// lib/Pages/EmailVerificationScreen.dart

import 'package:flutter/material.dart';

class EmailVerificationScreen extends StatelessWidget {
  final String email;

  const EmailVerificationScreen({Key? key, required this.email}) 
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Your Email'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mark_email_unread,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 32),
            Text(
              'Check Your Email',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'We\'ve sent a verification link to:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              email,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Click the link in the email to verify your account. '
              'The link will expire in 24 hours.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => _resendEmail(context),
              icon: Icon(Icons.refresh),
              label: Text('Resend Verification Email'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }

  void _resendEmail(BuildContext context) async {
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sending verification email...')),
    );

    // Call resend API
    final authService = AuthService(); // Use your service instance
    final result = await authService.resendVerificationEmail(email);

    // Show result
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: result['success'] ? Colors.green : Colors.red,
      ),
    );
  }
}
```

## Testing Checklist

- [ ] User can register and sees email verification message
- [ ] User receives verification email
- [ ] User cannot login without verifying email
- [ ] Error message clearly indicates email verification needed
- [ ] User can resend verification email
- [ ] User can verify email by clicking link
- [ ] After verification, user can login successfully
- [ ] Proper error handling for network issues
- [ ] Loading states shown during API calls

## Important Notes

1. **Token Storage**: Even though a token is returned on registration, don't auto-login the user. Require email verification first.

2. **Email Link Handling**: The verification link goes to your backend (`/api/auth/verify-email/:token`), not the Flutter app. After verification, users should manually go back to the app and login.

3. **Deep Linking** (Optional): For better UX, you could implement deep linking to automatically open the app after email verification.

4. **Expiration**: Verification tokens expire after 24 hours. Show this in your UI.

5. **Spam Folder**: Remind users to check spam/junk folders.

## Future Enhancements

- Add email verification status indicator in profile
- Implement deep linking for seamless verification
- Add "Verified" badge in user profile
- Send welcome email after verification
- Allow users to change email (with re-verification)

---

**Ready to integrate!** Follow the code examples above to add email verification to your Flutter app.
