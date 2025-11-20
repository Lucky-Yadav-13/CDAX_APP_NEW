// Phase 3: Payment Gateway Integration - Card Payment Screen
// Created for CDAX App card payment processing with strict validation

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/card_details.dart';
import '../../../providers/subscription_provider.dart';

class PaymentCardScreen extends StatefulWidget {
  const PaymentCardScreen({super.key});

  @override
  State<PaymentCardScreen> createState() => _PaymentCardScreenState();
}

class _PaymentCardScreenState extends State<PaymentCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  
  final _cardNumberFocus = FocusNode();
  final _expiryFocus = FocusNode();
  final _cvvFocus = FocusNode();
  final _nameFocus = FocusNode();

  bool _isSubmitEnabled = false;

  @override
  void initState() {
    super.initState();
    _setupValidationListeners();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    _cardNumberFocus.dispose();
    _expiryFocus.dispose();
    _cvvFocus.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _setupValidationListeners() {
    void validateForm() {
      setState(() {
        _isSubmitEnabled = _formKey.currentState?.validate() ?? false;
      });
    }

    _cardNumberController.addListener(validateForm);
    _expiryController.addListener(validateForm);
    _cvvController.addListener(validateForm);
    _nameController.addListener(validateForm);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = SubscriptionController.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Payment'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payment info card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (controller.selectedCourseTitle != null) ...[
                        Text('Course: ${controller.selectedCourseTitle}'),
                        const SizedBox(height: 4),
                      ],
                      Text('Plan: ${controller.currentPlan}'),
                      if (controller.selectedAmount != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Amount: ₹${controller.selectedAmount!.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Card form
                Text(
                  'Card Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Card number field
                TextFormField(
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _CardNumberInputFormatter(),
                    LengthLimitingTextInputFormatter(19), // 16 digits + 3 spaces
                  ],
                  validator: _validateCardNumber,
                  onChanged: (_) => _updateSubmitButton(),
                  decoration: const InputDecoration(
                    labelText: 'Card Number',
                    hintText: '1234 5678 9012 3456',
                    prefixIcon: Icon(Icons.credit_card),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Expiry and CVV row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _ExpiryDateInputFormatter(),
                          LengthLimitingTextInputFormatter(5),
                        ],
                        validator: _validateExpiry,
                        onChanged: (_) => _updateSubmitButton(),
                        decoration: const InputDecoration(
                          labelText: 'Expiry Date',
                          hintText: 'MM/YY',
                          prefixIcon: Icon(Icons.date_range),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        validator: _validateCVV,
                        onChanged: (_) => _updateSubmitButton(),
                        decoration: const InputDecoration(
                          labelText: 'CVV',
                          hintText: '123',
                          prefixIcon: Icon(Icons.security),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Cardholder name
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.words,
                  validator: _validateName,
                  onChanged: (_) => _updateSubmitButton(),
                  decoration: const InputDecoration(
                    labelText: 'Cardholder Name',
                    hintText: 'John Doe',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                // Security note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your card information is encrypted and secure. We never store your card details.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Submit button
                ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) {
                    return AppButton(
                      label: controller.isProcessing ? 'Processing...' : 'Pay Now',
                      onPressed: (_isSubmitEnabled && !controller.isProcessing) 
                          ? _processPayment 
                          : null,
                      icon: controller.isProcessing 
                          ? null 
                          : Icons.payment,
                      isExpanded: true,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Cancel button
                AppButton(
                  label: 'Cancel',
                  onPressed: () => context.pop(),
                  isExpanded: true,
                  isStyled: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateSubmitButton() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (_isSubmitEnabled != isValid) {
      setState(() {
        _isSubmitEnabled = isValid;
      });
    }
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Card number is required';
    }

    final sanitized = value.replaceAll(' ', '');
    if (sanitized.length < 13 || sanitized.length > 19) {
      return 'Invalid card number length';
    }

    // Create CardDetails for Luhn validation
    final cardDetails = CardDetails(
      cardNumber: value,
      expiryMonth: '01',
      expiryYear: '25',
      cvv: '123',
      holderName: 'Test',
    );

    if (!cardDetails.isValidLuhn) {
      return 'Invalid card number';
    }

    return null;
  }

  String? _validateExpiry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Expiry date is required';
    }

    if (value.length != 5) {
      return 'Enter MM/YY format';
    }

    final parts = value.split('/');
    if (parts.length != 2) {
      return 'Enter MM/YY format';
    }

    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || year == null) {
      return 'Invalid date format';
    }

    if (month < 1 || month > 12) {
      return 'Invalid month (01-12)';
    }

    final now = DateTime.now();
    final currentYear = now.year % 100;
    final currentMonth = now.month;

    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return 'Card has expired';
    }

    return null;
  }

  String? _validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    }

    if (value.length < 3 || value.length > 4) {
      return 'CVV must be 3-4 digits';
    }

    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Cardholder name is required';
    }

    if (value.trim().length < 2) {
      return 'Enter a valid name';
    }

    return null;
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = SubscriptionController.instance;

    try {
      // Parse expiry
      final expiryParts = _expiryController.text.split('/');
      final month = expiryParts[0];
      final year = '20${expiryParts[1]}'; // Convert YY to YYYY

      final cardDetails = CardDetails(
        cardNumber: _cardNumberController.text,
        expiryMonth: month,
        expiryYear: year,
        cvv: _cvvController.text,
        holderName: _nameController.text.trim(),
      );

      await controller.processCardPayment(
        cardDetails: cardDetails,
        amount: controller.selectedAmount ?? 0.0,
        courseId: controller.selectedCourseId,
        courseTitle: controller.selectedCourseTitle,
      );
      final result = controller.lastPaymentResult;

      if (mounted) {
        if (result?.success == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result?.message ?? 'Payment successful'),
              backgroundColor: AppColors.success,
            ),
          );
          // Navigate to result screen
          context.go('/dashboard/subscription/result');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result?.message ?? 'Payment failed'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment processing failed. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// Input formatter for card number with spaces
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    
    if (newText.length > oldValue.text.length) {
      // Adding characters
      final buffer = StringBuffer();
      for (int i = 0; i < newText.length; i++) {
        if (i > 0 && i % 4 == 0) {
          buffer.write(' ');
        }
        buffer.write(newText[i]);
      }
      
      final formatted = buffer.toString();
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    
    return newValue;
  }
}

/// Input formatter for expiry date MM/YY
class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    
    if (newText.length == 2 && oldValue.text.length == 1) {
      // Auto-add slash after MM
      return TextEditingValue(
        text: '$newText/',
        selection: const TextSelection.collapsed(offset: 3),
      );
    }
    
    if (newText.length > 2 && !newText.contains('/')) {
      // Insert slash if missing
      final month = newText.substring(0, 2);
      final year = newText.substring(2);
      final formatted = '$month/$year';
      
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    
    return newValue;
  }
}
