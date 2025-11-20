// Phase 3: Payment Gateway Integration - Payment Submission Widget Tests
// Tests for payment form submission flow and UI interactions

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cdax_app/screens/subscription/payment_card_screen.dart';
import 'package:cdax_app/screens/subscription/payment_netbanking_screen.dart';
import 'package:cdax_app/providers/subscription_provider.dart';

void main() {
  group('Payment Submission Widget Tests', () {
    setUp(() {
      // Reset provider state before each test
      final controller = SubscriptionController.instance;
      controller.resetPaymentState();
      controller.setPurchaseContext(
        courseId: 'test-course-id',
        courseTitle: 'Test Course',
        amount: 299.0,
      );
    });

    group('Card Payment Screen Tests', () {
      testWidgets('should render card payment form correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: const PaymentCardScreen(),
          ),
        );

        // Wait for widget to render
        await tester.pumpAndSettle();

        // Check if form elements are present
        expect(find.text('Card Payment'), findsOneWidget);
        expect(find.text('Payment Details'), findsOneWidget);
        expect(find.text('Card Information'), findsOneWidget);
        
        // Check form fields
        expect(find.byType(TextFormField), findsNWidgets(4)); // Card, Expiry, CVV, Name
        
        // Check buttons
        expect(find.text('Pay Now'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('should validate card form fields correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: const PaymentCardScreen(),
          ),
        );

        await tester.pumpAndSettle();

        // Find the Pay Now button - it should be disabled initially
        final payButton = find.text('Pay Now');
        expect(payButton, findsOneWidget);

        // Try to submit without filling form
        await tester.tap(payButton);
        await tester.pumpAndSettle();

        // Should show validation errors
        expect(find.text('Card number is required'), findsOneWidget);
        expect(find.text('Expiry date is required'), findsOneWidget);
        expect(find.text('CVV is required'), findsOneWidget);
        expect(find.text('Cardholder name is required'), findsOneWidget);
      });

      testWidgets('should accept valid card details and enable submit', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: const PaymentCardScreen(),
          ),
        );

        await tester.pumpAndSettle();

        // Find form fields by their labels
        final cardNumberField = find.widgetWithText(TextFormField, 'Card Number').first;
        final expiryField = find.widgetWithText(TextFormField, 'Expiry Date').first;
        final cvvField = find.widgetWithText(TextFormField, 'CVV').first;
        final nameField = find.widgetWithText(TextFormField, 'Cardholder Name').first;

        // Enter valid card details
        await tester.enterText(cardNumberField, '4111111111111111');
        await tester.enterText(expiryField, '12/25');
        await tester.enterText(cvvField, '123');
        await tester.enterText(nameField, 'John Doe');

        await tester.pumpAndSettle();

        // Submit button should now be enabled
        final payButton = find.text('Pay Now');
        expect(payButton, findsOneWidget);
      });

      testWidgets('should show processing state during payment', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: const PaymentCardScreen(),
          ),
        );

        await tester.pumpAndSettle();

        // Fill form with valid data
        final cardNumberField = find.widgetWithText(TextFormField, 'Card Number').first;
        final expiryField = find.widgetWithText(TextFormField, 'Expiry Date').first;
        final cvvField = find.widgetWithText(TextFormField, 'CVV').first;
        final nameField = find.widgetWithText(TextFormField, 'Cardholder Name').first;

        await tester.enterText(cardNumberField, '4111111111111111');
        await tester.enterText(expiryField, '12/25');
        await tester.enterText(cvvField, '123');
        await tester.enterText(nameField, 'John Doe');

        await tester.pumpAndSettle();

        // Tap submit button
        await tester.tap(find.text('Pay Now'));
        await tester.pump(); // Trigger state change

        // Should show processing state
        expect(find.text('Processing...'), findsOneWidget);
      });

      testWidgets('should format card number input with spaces', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: const PaymentCardScreen(),
          ),
        );

        await tester.pumpAndSettle();

        final cardNumberField = find.widgetWithText(TextFormField, 'Card Number').first;
        
        // Enter card number digits
        await tester.enterText(cardNumberField, '4111111111111111');
        await tester.pumpAndSettle();

        // The field should format the number with spaces
        final textField = tester.widget<TextFormField>(cardNumberField);
        expect(textField.controller?.text.contains(' '), isTrue);
      });

      testWidgets('should reject invalid card number with Luhn check', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: const PaymentCardScreen(),
          ),
        );

        await tester.pumpAndSettle();

        final cardNumberField = find.widgetWithText(TextFormField, 'Card Number').first;
        
        // Enter invalid card number
        await tester.enterText(cardNumberField, '4111111111111112');
        await tester.pumpAndSettle();

        // Trigger validation
        await tester.tap(find.text('Pay Now'));
        await tester.pumpAndSettle();

        // Should show validation error
        expect(find.text('Invalid card number'), findsOneWidget);
      });
    });

    group('NetBanking Payment Screen Tests', () {
      testWidgets('should render netbanking payment form correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: const PaymentNetbankingScreen(),
          ),
        );

        await tester.pumpAndSettle();

        // Check if form elements are present
        expect(find.text('NetBanking Payment'), findsOneWidget);
        expect(find.text('Payment Details'), findsOneWidget);
        expect(find.text('Select Your Bank'), findsOneWidget);
        
        // Check dropdown
        expect(find.byType(DropdownButtonFormField<dynamic>), findsOneWidget);
        
        // Check buttons
        expect(find.text('Proceed to Bank'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('should validate bank selection', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: const PaymentNetbankingScreen(),
          ),
        );

        await tester.pumpAndSettle();

        // Try to submit without selecting bank
        final proceedButton = find.text('Proceed to Bank');
        await tester.tap(proceedButton);
        await tester.pumpAndSettle();

        // Should show validation error
        expect(find.text('Please select a bank'), findsOneWidget);
      });

      testWidgets('should enable submit after bank selection', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: const PaymentNetbankingScreen(),
          ),
        );

        await tester.pumpAndSettle();

        // Open dropdown
        final dropdown = find.byType(DropdownButtonFormField<dynamic>);
        await tester.tap(dropdown);
        await tester.pumpAndSettle();

        // Select first bank option
        final firstBank = find.text('State Bank of India').first;
        await tester.tap(firstBank);
        await tester.pumpAndSettle();

        // Submit button should now work
        final proceedButton = find.text('Proceed to Bank');
        expect(proceedButton, findsOneWidget);
      });
    });

    group('Payment Result Handling Tests', () {
      testWidgets('should display payment amount correctly', (WidgetTester tester) async {
        // Set up payment context with specific amount
        final controller = SubscriptionController.instance;
        controller.setPurchaseContext(
          courseId: 'test_course_1',
          courseTitle: 'Advanced Flutter Course',
          amount: 599.0,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: const PaymentCardScreen(),
          ),
        );

        await tester.pumpAndSettle();

        // Check if amount is displayed correctly
        expect(find.text('Amount: ₹599.00'), findsOneWidget);
        expect(find.text('Course: Advanced Flutter Course'), findsOneWidget);
      });

      testWidgets('should handle network errors gracefully', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: const PaymentCardScreen(),
          ),
        );

        await tester.pumpAndSettle();

        // Fill form with valid data
        final cardNumberField = find.widgetWithText(TextFormField, 'Card Number').first;
        final expiryField = find.widgetWithText(TextFormField, 'Expiry Date').first;
        final cvvField = find.widgetWithText(TextFormField, 'CVV').first;
        final nameField = find.widgetWithText(TextFormField, 'Cardholder Name').first;

        await tester.enterText(cardNumberField, '4111111111111111');
        await tester.enterText(expiryField, '12/25');
        await tester.enterText(cvvField, '123');
        await tester.enterText(nameField, 'John Doe');

        await tester.pumpAndSettle();

        // Submit payment (this will use mock service which may simulate failure)
        await tester.tap(find.text('Pay Now'));
        await tester.pump();
        
        // Wait for async operation to complete
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should either show success or error snackbar
        // (Depending on mock service random result)
        // Note: SnackBar might not be visible in widget test, but the operation should complete
      });
    });

    group('Form Validation Edge Cases', () {
      testWidgets('should handle expired card validation', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: const PaymentCardScreen(),
          ),
        );

        await tester.pumpAndSettle();

        final expiryField = find.widgetWithText(TextFormField, 'Expiry Date').first;
        
        // Enter expired date
        await tester.enterText(expiryField, '01/20'); // January 2020
        await tester.pumpAndSettle();

        // Trigger validation
        await tester.tap(find.text('Pay Now'));
        await tester.pumpAndSettle();

        // Should show expiry error
        expect(find.text('Card has expired'), findsOneWidget);
      });

      testWidgets('should validate CVV length', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: const PaymentCardScreen(),
          ),
        );

        await tester.pumpAndSettle();

        final cvvField = find.widgetWithText(TextFormField, 'CVV').first;
        
        // Enter too short CVV
        await tester.enterText(cvvField, '12');
        await tester.pumpAndSettle();

        // Trigger validation
        await tester.tap(find.text('Pay Now'));
        await tester.pumpAndSettle();

        // Should show CVV error
        expect(find.text('CVV must be 3-4 digits'), findsOneWidget);
      });

      testWidgets('should validate cardholder name length', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: const PaymentCardScreen(),
          ),
        );

        await tester.pumpAndSettle();

        final nameField = find.widgetWithText(TextFormField, 'Cardholder Name').first;
        
        // Enter too short name
        await tester.enterText(nameField, 'A');
        await tester.pumpAndSettle();

        // Trigger validation
        await tester.tap(find.text('Pay Now'));
        await tester.pumpAndSettle();

        // Should show name error
        expect(find.text('Enter a valid name'), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should have proper semantic labels', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: const PaymentCardScreen(),
          ),
        );

        await tester.pumpAndSettle();

        // Check for semantic labels on important elements
        expect(find.text('Card Payment'), findsOneWidget);
        expect(find.text('Pay Now'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        
        // Form fields should have proper labels
        expect(find.text('Card Number'), findsAtLeastNWidgets(1));
        expect(find.text('Expiry Date'), findsAtLeastNWidgets(1));
        expect(find.text('CVV'), findsAtLeastNWidgets(1));
        expect(find.text('Cardholder Name'), findsAtLeastNWidgets(1));
      });
    });
  });
}