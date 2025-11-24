// Phase 3: Payment Gateway Integration - Card Details Model
// Created for CDAX App card payment validation and processing

import 'package:flutter/foundation.dart';

@immutable
class CardDetails {
  const CardDetails({
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
    required this.holderName,
  });

  final String cardNumber;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;
  final String holderName;

  /// Returns card number without spaces for processing
  String get sanitizedCardNumber => cardNumber.replaceAll(RegExp(r'[^0-9]'), '');

  /// Returns formatted card number with spaces for display
  String get formattedCardNumber {
    final sanitized = sanitizedCardNumber;
    if (sanitized.length < 4) return sanitized;
    
    final buffer = StringBuffer();
    for (int i = 0; i < sanitized.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(sanitized[i]);
    }
    return buffer.toString();
  }

  /// Returns masked card number for display (XXXX XXXX XXXX 1234)
  String get maskedCardNumber {
    final sanitized = sanitizedCardNumber;
    if (sanitized.length < 4) return sanitized;
    
    final lastFour = sanitized.substring(sanitized.length - 4);
    final maskedPart = 'X' * (sanitized.length - 4);
    // Return masked digits without inserting spaces so masked length matches original digit length
    return '$maskedPart$lastFour';
  }

  /// Returns expiry in MM/YY format
  String get formattedExpiry => '$expiryMonth/$expiryYear';

  /// Validates card using Luhn algorithm
  bool get isValidLuhn {
    // Reject if original input contains invalid characters (letters/symbols)
    if (RegExp(r'[^0-9\s]').hasMatch(cardNumber)) {
      return false;
    }

    final sanitized = sanitizedCardNumber;
    if (sanitized.isEmpty || sanitized.length < 13 || sanitized.length > 19) {
      return false;
    }

    int sum = 0;
    bool isEven = false;

    for (int i = sanitized.length - 1; i >= 0; i--) {
      int digit = int.tryParse(sanitized[i]) ?? 0;

      if (isEven) {
        digit *= 2;
        if (digit > 9) {
          digit = digit ~/ 10 + digit % 10;
        }
      }

      sum += digit;
      isEven = !isEven;
    }

    return sum % 10 == 0;
  }

  /// Detects card brand based on card number
  CardBrand get cardBrand {
    final sanitized = sanitizedCardNumber;
    if (sanitized.isEmpty) return CardBrand.unknown;

    if (sanitized.startsWith('4')) return CardBrand.visa;
    if (sanitized.startsWith('5') || sanitized.startsWith('2')) return CardBrand.mastercard;
    if (sanitized.startsWith('3')) return CardBrand.amex;
    if (sanitized.startsWith('6')) return CardBrand.discover;
    
    return CardBrand.unknown;
  }

  @override
  String toString() {
    return 'CardDetails{cardNumber: $maskedCardNumber, expiry: $formattedExpiry, holderName: $holderName}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardDetails &&
          runtimeType == other.runtimeType &&
          sanitizedCardNumber == other.sanitizedCardNumber &&
          expiryMonth == other.expiryMonth &&
          expiryYear == other.expiryYear &&
          holderName == other.holderName;

  @override
  int get hashCode => Object.hash(sanitizedCardNumber, expiryMonth, expiryYear, holderName);
}

enum CardBrand { visa, mastercard, amex, discover, unknown }

extension CardBrandExtension on CardBrand {
  String get displayName {
    switch (this) {
      case CardBrand.visa:
        return 'Visa';
      case CardBrand.mastercard:
        return 'MasterCard';
      case CardBrand.amex:
        return 'American Express';
      case CardBrand.discover:
        return 'Discover';
      case CardBrand.unknown:
        return 'Unknown';
    }
  }

  /// Returns expected CVV length for the card brand
  int get cvvLength {
    switch (this) {
      case CardBrand.amex:
        return 4;
      default:
        return 3;
    }
  }
}
