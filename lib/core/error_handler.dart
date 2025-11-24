// Error Handler
// Centralized error handling for API responses and exceptions
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_response.dart';
import '../config/api_constants.dart';

class ErrorHandler {
  /// Handle various types of errors and return standardized ApiResponse
  static ApiResponse<T> handleError<T>(dynamic error) {
    if (error is SocketException) {
      return ApiResponse.error(
        'No internet connection. Please check your network.',
        statusCode: 0,
      );
    } else if (error is TimeoutException) {
      return ApiResponse.error(
        'Request timeout. Please try again.',
        statusCode: 408,
      );
    } else if (error is HttpException) {
      return ApiResponse.error(
        'Network error: ${error.message}',
        statusCode: 500,
      );
    } else if (error is FormatException) {
      return ApiResponse.error(
        'Invalid response format.',
        statusCode: 422,
      );
    } else {
      return ApiResponse.error(
        'Unexpected error: ${error.toString()}',
        statusCode: 500,
      );
    }
  }
  
  /// Handle HTTP response errors
  static ApiResponse<T> handleHttpError<T>(http.Response response) {
    final statusCode = response.statusCode;
    String errorMessage;
    
    try {
      final errorBody = json.decode(response.body);
      errorMessage = errorBody['message'] ?? errorBody['error'] ?? _getDefaultErrorMessage(statusCode);
    } catch (e) {
      errorMessage = _getDefaultErrorMessage(statusCode);
    }
    
    return ApiResponse.error(
      errorMessage,
      statusCode: statusCode,
      metadata: {
        'responseBody': response.body,
        'headers': response.headers,
      },
    );
  }
  
  /// Get default error message based on status code
  static String _getDefaultErrorMessage(int statusCode) {
    switch (statusCode) {
      case ApiConstants.badRequest:
        return 'Invalid request. Please check your input.';
      case ApiConstants.unauthorized:
        return 'Authentication failed. Please login again.';
      case ApiConstants.forbidden:
        return 'You don\'t have permission to access this resource.';
      case ApiConstants.notFound:
        return 'Resource not found.';
      case ApiConstants.serverError:
        return 'Server error. Please try again later.';
      case 422:
        return 'Validation error. Please check your input.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
  
  /// Check if error is network related
  static bool isNetworkError(dynamic error) {
    return error is SocketException || 
           error is TimeoutException ||
           error is HttpException;
  }
  
  /// Check if error requires authentication
  static bool isAuthError(dynamic error) {
    if (error is http.Response) {
      return error.statusCode == ApiConstants.unauthorized;
    }
    return false;
  }
  
  /// Check if error is server related
  static bool isServerError(dynamic error) {
    if (error is http.Response) {
      return error.statusCode >= 500;
    }
    return false;
  }
  
  /// Check if error is client related (4xx)
  static bool isClientError(dynamic error) {
    if (error is http.Response) {
      return error.statusCode >= 400 && error.statusCode < 500;
    }
    return false;
  }
  
  /// Extract validation errors from response
  static Map<String, List<String>> extractValidationErrors(http.Response response) {
    try {
      final body = json.decode(response.body);
      if (body['errors'] != null && body['errors'] is Map) {
        final errors = <String, List<String>>{};
        (body['errors'] as Map).forEach((key, value) {
          if (value is List) {
            errors[key] = value.cast<String>();
          } else if (value is String) {
            errors[key] = [value];
          }
        });
        return errors;
      }
    } catch (e) {
      // Ignore JSON parsing errors
    }
    return {};
  }
  
  /// Log error for debugging (only in debug mode)
  static void logError(dynamic error, [StackTrace? stackTrace]) {
    // Only log in debug mode
    assert(() {
      if (kDebugMode) {
        debugPrint('🔥 API Error: $error');
      }
      if (stackTrace != null) {
        if (kDebugMode) {
          debugPrint('📍 Stack Trace: $stackTrace');
        }
      }
      return true;
    }());
  }
}

/// Custom exception classes for specific error types
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);
  
  @override
  String toString() => 'AuthenticationException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>>? fieldErrors;
  
  ValidationException(this.message, [this.fieldErrors]);
  
  @override
  String toString() => 'ValidationException: $message';
}

class ServerException implements Exception {
  final String message;
  final int statusCode;
  
  ServerException(this.message, this.statusCode);
  
  @override
  String toString() => 'ServerException($statusCode): $message';
}