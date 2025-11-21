// Phase 3: Payment Gateway Integration - Razorpay Gateway Adapter
// Created for CDAX App payment gateway abstraction with mock/production toggle

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../models/payment_result.dart';
import '../models/card_details.dart';
import '../models/netbanking_details.dart';
import '../models/transfer_details.dart';
import 'mock_payment_service.dart';
import 'payment_service.dart';

// IMPORTANT: Set to false for production and provide environment variable
// Set to false for production-ready backend integration
const bool useMockPayment = false;

/// Response from payment gateway operations
class PaymentGatewayResponse {
  const PaymentGatewayResponse({
    required this.success,
    required this.message,
    this.paymentId,
    this.orderId,
    this.signature,
    this.errorCode,
  });

  final bool success;
  final String message;
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final String? errorCode;
}

/// Adapter class that abstracts payment gateway operations
/// Supports both mock mode (for development) and Razorpay integration (for production)
class PaymentGatewayAdapter {
  PaymentGatewayAdapter._();
  
  static final PaymentGatewayAdapter _instance = PaymentGatewayAdapter._();
  static PaymentGatewayAdapter get instance => _instance;

  Razorpay? _razorpay;
  Completer<PaymentGatewayResponse>? _paymentCompleter;

  /// Initialize the payment gateway (only called in production mode)
  Future<void> initialize() async {
    if (useMockPayment) {
      debugPrint('PaymentGatewayAdapter: Running in MOCK mode');
      return;
    }

    try {
      // Initialize Razorpay only in production mode
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
      
      debugPrint('PaymentGatewayAdapter: Razorpay initialized successfully');
    } catch (e) {
      debugPrint('PaymentGatewayAdapter: Failed to initialize Razorpay: $e');
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
    _paymentCompleter = null;
  }

  /// Create order on backend (mocked in development)
  Future<String> createOrderOnBackend({
    required double amount,
    required String currency,
    String? courseId,
    String? courseTitle,
    Map<String, dynamic>? metadata,
  }) async {
    if (useMockPayment) {
      return await MockPaymentService.createOrder(
        amount: amount,
        currency: currency,
        courseId: courseId,
        courseTitle: courseTitle,
        metadata: metadata,
      );
    }

    // Production: Use PaymentService for backend integration
    if (courseId == null || courseTitle == null) {
      throw Exception('Course ID and title are required for order creation');
    }
    
    final orderData = await PaymentService.createPurchaseOrder(
      courseId: courseId,
      courseTitle: courseTitle,
      amount: amount,
    );
    
    return orderData['orderId'] as String;
  }

  /// Open Razorpay checkout for payment
  Future<PaymentGatewayResponse> openCheckout({
    required String orderId,
    required double amount,
    required String currency,
    required String name,
    required String description,
    String? email,
    String? contact,
    Map<String, dynamic>? notes,
  }) async {
    if (useMockPayment) {
      // In mock mode, simulate payment flow based on payment type
      await Future.delayed(const Duration(seconds: 2));
      
      // For mock, we'll simulate a successful payment
      return const PaymentGatewayResponse(
        success: true,
        message: 'Mock payment successful',
        paymentId: 'pay_mock_12345',
        orderId: 'order_mock_12345',
        signature: 'mock_signature_abcdef',
      );
    }

    if (_razorpay == null) {
      throw StateError('Razorpay not initialized. Call initialize() first.');
    }

    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      throw StateError('Payment already in progress');
    }

    try {
      _paymentCompleter = Completer<PaymentGatewayResponse>();
      
      // Configure payment options
      final options = {
        'key': _getRazorpayKeyId(), // Get from environment variable
        'amount': (amount * 100).toInt(), // Convert to paise
        'currency': currency.toUpperCase(),
        'name': name,
        'description': description,
        'order_id': orderId,
        'prefill': {
          if (email != null) 'email': email,
          if (contact != null) 'contact': contact,
        },
        'notes': notes ?? {},
        'theme': {
          'color': '#1976D2', // App primary color
        },
        'modal': {
          'ondismiss': () {
            if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
              _paymentCompleter!.complete(PaymentGatewayResponse(
                success: false,
                message: 'Payment cancelled by user',
                errorCode: 'USER_CANCELLED',
              ));
            }
          }
        },
      };

      _razorpay!.open(options);
      
      return await _paymentCompleter!.future;
    } catch (e) {
      _paymentCompleter = null;
      debugPrint('PaymentGatewayAdapter: Error opening checkout: $e');
      return PaymentGatewayResponse(
        success: false,
        message: 'Failed to open payment: ${e.toString()}',
        errorCode: 'CHECKOUT_ERROR',
      );
    }
  }

  /// Process card payment (using Razorpay or mock)
  Future<PaymentResult> processCardPayment({
    required CardDetails cardDetails,
    required double amount,
    required String currency,
    String? courseId,
    String? courseTitle,
  }) async {
    if (useMockPayment) {
      return await MockPaymentService.processCardPayment(
        cardDetails: cardDetails,
        amount: amount,
        currency: currency,
        courseId: courseId,
        courseTitle: courseTitle,
      );
    }

    try {
      // Step 1: Create order on backend
      final orderId = await createOrderOnBackend(
        amount: amount,
        currency: currency,
        courseId: courseId,
        courseTitle: courseTitle,
      );

      // Step 2: Open Razorpay checkout
      final response = await openCheckout(
        orderId: orderId,
        amount: amount,
        currency: currency,
        name: 'CDAX App',
        description: courseTitle != null ? 'Course: $courseTitle' : 'Subscription Payment',
      );

      // Step 3: Verify payment on backend if successful
      if (response.success) {
        return await verifyPaymentOnBackend(
          paymentId: response.paymentId!,
          orderId: response.orderId!,
          signature: response.signature,
        );
      } else {
        return PaymentResult.failure(
          message: response.message,
          errorCode: response.errorCode,
          orderId: orderId,
        );
      }
    } catch (e) {
      debugPrint('PaymentGatewayAdapter: Card payment failed: $e');
      return PaymentResult.failure(
        message: 'Payment processing failed. Please try again.',
        errorCode: 'PROCESSING_ERROR',
      );
    }
  }

  /// Process netbanking payment
  Future<PaymentResult> processNetbankingPayment({
    required NetbankingDetails bankDetails,
    required double amount,
    required String currency,
    String? courseId,
    String? courseTitle,
  }) async {
    if (useMockPayment) {
      return await MockPaymentService.processNetbankingPayment(
        bankDetails: bankDetails,
        amount: amount,
        currency: currency,
        courseId: courseId,
        courseTitle: courseTitle,
      );
    }

    try {
      // Similar flow to card payment but with netbanking method
      final orderId = await createOrderOnBackend(
        amount: amount,
        currency: currency,
        courseId: courseId,
        courseTitle: courseTitle,
      );

      final response = await openCheckout(
        orderId: orderId,
        amount: amount,
        currency: currency,
        name: 'CDAX App',
        description: courseTitle != null ? 'Course: $courseTitle' : 'Subscription Payment',
        notes: {'payment_method': 'netbanking', 'bank': bankDetails.bankCode},
      );

      if (response.success) {
        return await verifyPaymentOnBackend(
          paymentId: response.paymentId!,
          orderId: response.orderId!,
          signature: response.signature,
        );
      } else {
        return PaymentResult.failure(
          message: response.message,
          errorCode: response.errorCode,
          orderId: orderId,
        );
      }
    } catch (e) {
      debugPrint('PaymentGatewayAdapter: Netbanking payment failed: $e');
      return PaymentResult.failure(
        message: 'Payment processing failed. Please try again.',
        errorCode: 'PROCESSING_ERROR',
      );
    }
  }

  /// Process bank transfer payment
  Future<PaymentResult> processTransferPayment({
    required TransferDetails transferDetails,
    required double amount,
    required String currency,
    String? courseId,
    String? courseTitle,
  }) async {
    if (useMockPayment) {
      return await MockPaymentService.processTransferPayment(
        transferDetails: transferDetails,
        amount: amount,
        currency: currency,
        courseId: courseId,
        courseTitle: courseTitle,
      );
    }

    // Note: Bank transfers typically don't go through Razorpay's immediate payment flow
    // They are usually handled via bank transfer APIs or manual verification
    // For now, we'll use the mock implementation
    return await MockPaymentService.processTransferPayment(
      transferDetails: transferDetails,
      amount: amount,
      currency: currency,
      courseId: courseId,
      courseTitle: courseTitle,
    );
  }

  /// Verify payment on backend (mocked in development)
  Future<PaymentResult> verifyPaymentOnBackend({
    required String paymentId,
    required String orderId,
    String? signature,
  }) async {
    if (useMockPayment) {
      return await MockPaymentService.verifyPayment(
        paymentId: paymentId,
        orderId: orderId,
        signature: signature,
      );
    }

    // TODO_PRODUCTION: Replace with actual backend verification
    // Example implementation:
    // final response = await http.post(
    //   Uri.parse('${ApiConfig.baseUrl}/payments/verify'),
    //   headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    //   body: jsonEncode({
    //     'payment_id': paymentId,
    //     'order_id': orderId,
    //     'signature': signature,
    //   }),
    // );
    // return PaymentResult.fromJson(jsonDecode(response.body));
    
    throw UnimplementedError('Backend integration required for production mode');
  }

  // Razorpay event handlers
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _paymentCompleter!.complete(PaymentGatewayResponse(
        success: true,
        message: 'Payment successful',
        paymentId: response.paymentId,
        orderId: response.orderId,
        signature: response.signature,
      ));
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _paymentCompleter!.complete(PaymentGatewayResponse(
        success: false,
        message: response.message ?? 'Payment failed',
        errorCode: response.code?.toString(),
      ));
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _paymentCompleter!.complete(PaymentGatewayResponse(
        success: false,
        message: 'External wallet selected: ${response.walletName}',
        errorCode: 'EXTERNAL_WALLET',
      ));
    }
  }

  /// Get Razorpay Key ID from environment variable or secure storage
  String _getRazorpayKeyId() {
    // TODO_PRODUCTION: Get from environment variable or secure configuration
    // Example: return Platform.environment['RAZORPAY_KEY_ID'] ?? '';
    
    // For now, return a placeholder (should never be committed to repo)
    if (kDebugMode) {
      return 'rzp_test_placeholder_key_id'; // Test key placeholder
    }
    
    throw UnimplementedError('Razorpay Key ID must be configured via environment variable');
  }
}
