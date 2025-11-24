// Base API Service
// Abstract base class for all API services with common functionality
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_constants.dart';
import '../config/environment.dart';
import 'api_response.dart';
import 'error_handler.dart';

abstract class BaseApiService {
  final http.Client _client = http.Client();
  String? _authToken;
  
  // Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  // Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }
  
  // Get common headers
  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }
  
  // Build full URL
  String _buildUrl(String endpoint) {
    return '${EnvironmentConfig.apiBaseUrl}${ApiConstants.apiVersion}$endpoint';
  }
  
  // Generic GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(endpoint));
      final finalUri = queryParameters != null
          ? uri.replace(queryParameters: queryParameters)
          : uri;
      
      final response = await _client
          .get(finalUri, headers: _getHeaders())
          .timeout(Duration(seconds: ApiConstants.connectionTimeout));
      
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ErrorHandler.handleError<T>(e);
    }
  }
  
  // Generic POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(endpoint));
      final response = await _client
          .post(
            uri,
            headers: _getHeaders(),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(Duration(seconds: ApiConstants.connectionTimeout));
      
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ErrorHandler.handleError<T>(e);
    }
  }
  
  // Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(endpoint));
      final response = await _client
          .put(
            uri,
            headers: _getHeaders(),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(Duration(seconds: ApiConstants.connectionTimeout));
      
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ErrorHandler.handleError<T>(e);
    }
  }
  
  // Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(endpoint));
      final response = await _client
          .delete(uri, headers: _getHeaders())
          .timeout(Duration(seconds: ApiConstants.connectionTimeout));
      
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ErrorHandler.handleError<T>(e);
    }
  }
  
  // Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (fromJson != null) {
        try {
          final data = json.decode(response.body);
          return ApiResponse.success(fromJson(data));
        } catch (e) {
          return ApiResponse.error('Failed to parse response: ${e.toString()}');
        }
      } else {
        return ApiResponse.success(response.body as T);
      }
    } else {
      return ErrorHandler.handleHttpError<T>(response);
    }
  }
  
  // Dispose resources
  void dispose() {
    _client.close();
  }
}