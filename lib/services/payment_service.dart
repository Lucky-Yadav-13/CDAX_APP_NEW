// Backend Payment Service for CDAX App
// Handles purchase creation and payment verification with backend APIs

import 'dart:convert';
import 'dart:developer';
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
    String? userId,
  }) async {
    final url = Uri.parse('${BackendConfig.baseUrl}/api/course/purchase').replace(
      queryParameters: {
        'userId': userId ?? '1',
        'courseId': courseId,
      },
    );
    
    log('📡 Creating purchase order on backend...');
    log('   ├─ Course ID: $courseId');
    log('   ├─ User ID: ${userId ?? '1'}');
    log('   ├─ Amount: $amount $currency');
    log('   └─ URL: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // TODO: Add authentication headers when user auth is implemented
          // 'Authorization': 'Bearer ${await AuthService.getToken()}',
        },
      ).timeout(timeout);

      log('   📨 Response status: ${response.statusCode}');
      log('   📨 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);
        log('   ✅ Purchase order created successfully');
        log('   📋 Order ID: ${result['orderId']}');
        
        // Return standardized format for payment gateway
        return {
          'success': result['success'] ?? true,
          'orderId': result['orderId'],
          'amount': (amount * 100).toInt(), // Convert to paisa for Razorpay
          'currency': currency,
          'courseId': courseId,
          'userId': userId ?? '1',
          'message': result['message'],
        };
      } else {
        log('   ❌ Failed to create purchase order: ${response.statusCode}');
        throw HttpException('Failed to create purchase order: ${response.statusCode}');
      }
    } catch (e) {
      log('   💥 Error creating purchase order: $e');
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
    
    log('📡 Verifying payment with backend...');
    log('   ├─ Order ID: $orderId');
    log('   ├─ Payment ID: $paymentId');
    log('   └─ URL: $url');

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

      log('   📨 Response status: ${response.statusCode}');
      log('   📨 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);
        log('   ✅ Payment verification successful');
        
        return PaymentResult(
          success: result['success'] ?? true,
          message: result['message'] ?? 'Payment verified successfully',
          paymentId: paymentId,
          orderId: orderId,
          signature: signature,
        );
      } else {
        log('   ❌ Payment verification failed: ${response.statusCode}');
        final errorBody = response.body.isNotEmpty ? json.decode(response.body) : {};
        return PaymentResult(
          success: false,
          message: errorBody['message'] ?? 'Payment verification failed',
          paymentId: paymentId,
          orderId: orderId,
        );
      }
    } catch (e) {
      log('   💥 Error verifying payment: $e');
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
    required String courseId,
    String? userId,
  }) async {
    final url = Uri.parse('${BackendConfig.baseUrl}/api/course/purchased').replace(
      queryParameters: {
        'userId': userId ?? '1',
        'courseId': courseId,
      },
    );
    
    log('📡 Checking purchase status...');
    log('   ├─ Course ID: $courseId');
    log('   ├─ User ID: ${userId ?? '1'}');
    log('   └─ URL: $url');

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

      log('   📨 Response status: ${response.statusCode}');
      log('   📨 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);
        log('   ✅ Purchase status retrieved');
        return result;
      } else {
        log('   ❌ Failed to get purchase status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('   💥 Error getting purchase status: $e');
      return null;
    }
  }
}