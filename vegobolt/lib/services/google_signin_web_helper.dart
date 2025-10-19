import 'dart:async';
import 'dart:js' as js;
import 'package:flutter/foundation.dart';

/// Web-specific Google Sign-In Helper
/// 
/// This uses the custom JavaScript handler defined in index.html
/// to avoid the popup_closed error that occurs with google_sign_in package
class GoogleSignInWebHelper {
  /// Check if the web helper is available
  static bool isAvailable() {
    if (!kIsWeb) return false;
    
    try {
      final context = js.context;
      return context.hasProperty('googleSignInWeb');
    } catch (e) {
      print('[GoogleSignInWebHelper] Error checking availability: $e');
      return false;
    }
  }
  
  /// Sign in using the web helper
  /// 
  /// Returns a Map with user data or null if cancelled/failed
  static Future<Map<String, dynamic>?> signIn() async {
    if (!kIsWeb) {
      throw UnsupportedError('This helper is only for web platform');
    }
    
    try {
      print('[GoogleSignInWebHelper] Starting sign-in...');
      
      final completer = Completer<Map<String, dynamic>?>();
      
      // Call the JavaScript function
      final signInPromise = js.context.callMethod('eval', [
        '''
        (async function() {
          try {
            console.log('[GoogleSignInWebHelper] Calling googleSignInWeb.signIn()');
            const result = await window.googleSignInWeb.signIn();
            console.log('[GoogleSignInWebHelper] Sign-in result:', result);
            return result;
          } catch (error) {
            console.error('[GoogleSignInWebHelper] Sign-in error:', error);
            throw error;
          }
        })()
        '''
      ]);
      
      // Convert JS Promise to Dart Future
      js.JsObject.fromBrowserObject(signInPromise).callMethod('then', [
        (result) {
          if (result == null) {
            print('[GoogleSignInWebHelper] Sign-in cancelled');
            completer.complete(null);
            return;
          }
          
          // Convert JS object to Dart Map
          final Map<String, dynamic> userData = {
            'accessToken': _getProperty(result, 'accessToken'),
            'idToken': _getProperty(result, 'idToken'),
            'email': _getProperty(result, 'email'),
            'displayName': _getProperty(result, 'displayName'),
            'photoUrl': _getProperty(result, 'photoUrl'),
            'id': _getProperty(result, 'id'),
          };
          
          print('[GoogleSignInWebHelper] User data: $userData');
          completer.complete(userData);
        },
        (error) {
          print('[GoogleSignInWebHelper] Error: $error');
          completer.completeError(error?.toString() ?? 'Unknown error');
        }
      ]);
      
      // Timeout after 60 seconds
      return completer.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          print('[GoogleSignInWebHelper] Sign-in timed out');
          return null;
        },
      );
    } catch (e) {
      print('[GoogleSignInWebHelper] Exception: $e');
      return null;
    }
  }
  
  /// Helper to get property from JS object
  static dynamic _getProperty(dynamic jsObject, String property) {
    try {
      if (jsObject is js.JsObject && jsObject.hasProperty(property)) {
        return jsObject[property];
      }
      return null;
    } catch (e) {
      print('[GoogleSignInWebHelper] Error getting property $property: $e');
      return null;
    }
  }
}
