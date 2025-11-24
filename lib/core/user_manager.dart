// User Manager
// Handles user session management using Flutter Secure Storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserManager {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  // Storage keys
  static const String _emailKey = 'user_email';
  static const String _nameKey = 'user_name';
  static const String _mobileKey = 'user_mobile';
  static const String _subscriptionKey = 'user_subscription';
  
  /// Set user email
  static Future<void> setEmail(String email) async {
    await _storage.write(key: _emailKey, value: email);
  }
  
  /// Get user email
  static Future<String?> getEmail() async {
    return await _storage.read(key: _emailKey);
  }
  
  /// Set user name
  static Future<void> setName(String name) async {
    await _storage.write(key: _nameKey, value: name);
  }
  
  /// Get user name
  static Future<String?> getName() async {
    return await _storage.read(key: _nameKey);
  }
  
  /// Set user mobile
  static Future<void> setMobile(String mobile) async {
    await _storage.write(key: _mobileKey, value: mobile);
  }
  
  /// Get user mobile
  static Future<String?> getMobile() async {
    return await _storage.read(key: _mobileKey);
  }
  
  /// Set subscription status
  static Future<void> setSubscriptionStatus(bool isSubscribed) async {
    await _storage.write(key: _subscriptionKey, value: isSubscribed.toString());
  }
  
  /// Get subscription status
  static Future<bool> getSubscriptionStatus() async {
    final status = await _storage.read(key: _subscriptionKey);
    return status == 'true';
  }
  
  /// Clear all user session data
  static Future<void> clearSession() async {
    await _storage.deleteAll();
  }
  
  /// Check if user session exists
  static Future<bool> hasSession() async {
    final email = await getEmail();
    return email != null && email.isNotEmpty;
  }
}