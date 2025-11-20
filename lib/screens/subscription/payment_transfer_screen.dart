// Phase 3: Payment Gateway Integration - Bank Transfer Payment Screen
// Created for CDAX App bank transfer payment processing with IFSC validation

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/transfer_details.dart';
import '../../../providers/subscription_provider.dart';

class PaymentTransferScreen extends StatefulWidget {
  const PaymentTransferScreen({super.key});

  @override
  State<PaymentTransferScreen> createState() => _PaymentTransferScreenState();
}

class _PaymentTransferScreenState extends State<PaymentTransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isSubmitEnabled = false;

  @override
  void initState() {
    super.initState();
    _setupValidationListeners();
  }

  @override
  void dispose() {
    _accountController.dispose();
    _ifscController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _setupValidationListeners() {
    void validateForm() {
      setState(() {
        _isSubmitEnabled = _formKey.currentState?.validate() ?? false;
      });
    }

    _accountController.addListener(validateForm);
    _ifscController.addListener(validateForm);
    _nameController.addListener(validateForm);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = SubscriptionController.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Transfer'),
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

                // Bank account form
                Text(
                  'Bank Account Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Account number field
                TextFormField(
                  controller: _accountController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(18),
                  ],
                  validator: _validateAccountNumber,
                  onChanged: (_) => _updateSubmitButton(),
                  decoration: const InputDecoration(
                    labelText: 'Account Number',
                    hintText: 'Enter your bank account number',
                    prefixIcon: Icon(Icons.account_balance_wallet),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // IFSC code field
                TextFormField(
                  controller: _ifscController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                    LengthLimitingTextInputFormatter(11),
                  ],
                  validator: _validateIFSC,
                  onChanged: (_) => _updateSubmitButton(),
                  decoration: const InputDecoration(
                    labelText: 'IFSC Code',
                    hintText: 'e.g., SBIN0001234',
                    prefixIcon: Icon(Icons.code),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Account holder name
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.words,
                  validator: _validateName,
                  onChanged: (_) => _updateSubmitButton(),
                  decoration: const InputDecoration(
                    labelText: 'Account Holder Name',
                    hintText: 'As per bank records',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                // IFSC helper
                if (_ifscController.text.length >= 4)
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
                          Icons.check_circle_outline,
                          color: AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getBankNameFromIFSC(_ifscController.text),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Security note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bank transfers may take 2-3 business days to process. Your course access will be activated after payment verification.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
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
                      label: controller.isProcessing ? 'Processing...' : 'Initiate Transfer',
                      onPressed: (_isSubmitEnabled && !controller.isProcessing) 
                          ? _processPayment 
                          : null,
                      icon: controller.isProcessing 
                          ? null 
                          : Icons.send,
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

  String? _validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Account number is required';
    }

    if (value.length < 9 || value.length > 18) {
      return 'Account number must be 9-18 digits';
    }

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Account number should contain only digits';
    }

    return null;
  }

  String? _validateIFSC(String? value) {
    if (value == null || value.isEmpty) {
      return 'IFSC code is required';
    }

    final ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
    if (!ifscRegex.hasMatch(value.toUpperCase())) {
      return 'Invalid IFSC format (e.g., SBIN0001234)';
    }

    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Account holder name is required';
    }

    if (value.trim().length < 2) {
      return 'Enter a valid name';
    }

    return null;
  }

  String _getBankNameFromIFSC(String ifsc) {
    if (ifsc.length < 4) return '';
    
    final bankName = BankIfscCodes.getBankName(ifsc);
    return bankName ?? 'Bank: ${ifsc.substring(0, 4)}';
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = SubscriptionController.instance;

    try {
      final transferDetails = TransferDetails(
        accountNumber: _accountController.text.trim(),
        ifscCode: _ifscController.text.trim().toUpperCase(),
        accountHolderName: _nameController.text.trim(),
      );

      await controller.processTransferPayment(
        transferDetails: transferDetails,
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

/// Input formatter to convert text to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
