// Phase 3: Payment Gateway Integration - NetBanking Payment Screen
// Created for CDAX App netbanking payment processing with bank selection

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/netbanking_details.dart';
import '../../../providers/subscription_provider.dart';

class PaymentNetbankingScreen extends StatefulWidget {
  const PaymentNetbankingScreen({super.key});

  @override
  State<PaymentNetbankingScreen> createState() => _PaymentNetbankingScreenState();
}

class _PaymentNetbankingScreenState extends State<PaymentNetbankingScreen> {
  final _formKey = GlobalKey<FormState>();
  NetbankingDetails? _selectedBank;
  bool _isSubmitEnabled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = SubscriptionController.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NetBanking Payment'),
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

                // Bank selection
                Text(
                  'Select Your Bank',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Bank dropdown
                DropdownButtonFormField<NetbankingDetails>(
                  value: _selectedBank,
                  decoration: const InputDecoration(
                    labelText: 'Choose Bank',
                    prefixIcon: Icon(Icons.account_balance),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a bank';
                    }
                    return null;
                  },
                  onChanged: (NetbankingDetails? value) {
                    setState(() {
                      _selectedBank = value;
                      _isSubmitEnabled = value != null;
                    });
                  },
                  items: SupportedBanks.banks.map((bank) {
                    return DropdownMenuItem<NetbankingDetails>(
                      value: bank,
                      child: SizedBox(
                        width: 280, // Fixed width to prevent unbounded constraints
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.account_balance,
                                color: theme.primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    bank.bankName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  bank.bankCode,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Security note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You will be redirected to your bank\'s secure website to complete the payment.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.info,
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
                      label: controller.isProcessing ? 'Processing...' : 'Proceed to Bank',
                      onPressed: (_isSubmitEnabled && !controller.isProcessing) 
                          ? _processPayment 
                          : null,
                      icon: controller.isProcessing 
                          ? null 
                          : Icons.arrow_forward,
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

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate() || _selectedBank == null) return;

    final controller = SubscriptionController.instance;

    try {
      await controller.processNetbankingPayment(
        netBankingDetails: _selectedBank!,
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
