// Backend Payment Service for CDAX App
// Handles purchase creation and payment verification with backend APIs

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../config/backend_config.dart';
import '../models/payment_result.dart';

/// Service for handling backend payment operations
class PaymentService {
  static const Duration timeout = Duration(seconds: 30);

  /// Create a purchase order on the backend
  /// Returns order details needed for payment gateway
  static Future<Map<String, dynamic>> createPurchaseOrder({
    required String courseId,
    required String courseTitle,
    required double amount,
    String currency = 'INR',
  }) async {
    final url = Uri.parse('${BackendConfig.baseUrl}/api/courses/$courseId/purchase');
    
    print('📡 Creating purchase order on backend...');
    print('   ├─ Course ID: $courseId');
    print('   ├─ Amount: $amount $currency');
    print('   └─ URL: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // TODO: Add authentication headers when user auth is implemented
          // 'Authorization': 'Bearer ${await AuthService.getToken()}',
        },
        body: json.encode({
          'courseId': courseId,
          'courseTitle': courseTitle,
          'amount': amount,
          'currency': currency,
        }),
      ).timeout(timeout);

      print('   📨 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> result = json.decode(response.body);
        print('   ✅ Purchase order created successfully');
        print('   📋 Order ID: ${result['orderId']}');
        return result;
      } else {
        print('   ❌ Failed to create purchase order: ${response.statusCode}');
        throw HttpException('Failed to create purchase order: ${response.statusCode}');
      }
    } catch (e) {
      print('   💥 Error creating purchase order: $e');
      rethrow;
    }
  }

  /// Verify payment with backend after gateway completion
  /// This confirms the payment and unlocks the course
  static Future<PaymentResult> verifyPayment({
    required String orderId,
    required String paymentId,
    String? signature,
    Map<String, dynamic>? additionalData,
  }) async {
    final url = Uri.parse('${BackendConfig.baseUrl}/api/payments/verify');
    
    print('📡 Verifying payment with backend...');
    print('   ├─ Order ID: $orderId');
    print('   ├─ Payment ID: $paymentId');
    print('   └─ URL: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // TODO: Add authentication headers when user auth is implemented
          // 'Authorization': 'Bearer ${await AuthService.getToken()}',
        },
        body: json.encode({
          'orderId': orderId,
          'paymentId': paymentId,
          'signature': signature,
          'additionalData': additionalData,
        }),
      ).timeout(timeout);

      print('   📨 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);
        print('   ✅ Payment verification successful');
        
        return PaymentResult(
          success: result['success'] ?? true,
          message: result['message'] ?? 'Payment verified successfully',
          paymentId: paymentId,
          orderId: orderId,
          signature: signature,
        );
      } else {
        print('   ❌ Payment verification failed: ${response.statusCode}');
        final errorBody = response.body.isNotEmpty ? json.decode(response.body) : {};
        return PaymentResult(
          success: false,
          message: errorBody['message'] ?? 'Payment verification failed',
          paymentId: paymentId,
          orderId: orderId,
        );
      }
    } catch (e) {
      print('   💥 Error verifying payment: $e');
      return PaymentResult(
        success: false,
        message: 'Payment verification error: ${e.toString()}',
        paymentId: paymentId,
        orderId: orderId,
      );
    }
  }

  /// Get purchase status from backend
  /// Used for polling or checking purchase state
  static Future<Map<String, dynamic>?> getPurchaseStatus({
    required String orderId,
  }) async {
    final url = Uri.parse('${BackendConfig.baseUrl}/api/purchases/$orderId/status');
    
    print('📡 Checking purchase status...');
    print('   ├─ Order ID: $orderId');
    print('   └─ URL: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // TODO: Add authentication headers when user auth is implemented
          // 'Authorization': 'Bearer ${await AuthService.getToken()}',
        },
      ).timeout(timeout);

      print('   📨 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);
        print('   ✅ Purchase status retrieved');
        return result;
      } else {
        print('   ❌ Failed to get purchase status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('   💥 Error getting purchase status: $e');
      return null;
    }
  }
}