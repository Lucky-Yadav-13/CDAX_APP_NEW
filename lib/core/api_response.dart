/// API Response Wrapper
/// Standardized response format for all API calls
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final int? statusCode;
  final Map<String, dynamic>? metadata;
  
  const ApiResponse._({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.statusCode,
    this.metadata,
  });
  
  /// Create a successful response
  factory ApiResponse.success(
    T data, {
    String? message,
    int? statusCode,
    Map<String, dynamic>? metadata,
  }) {
    return ApiResponse._(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode ?? 200,
      metadata: metadata,
    );
  }
  
  /// Create an error response
  factory ApiResponse.error(
    String error, {
    int? statusCode,
    Map<String, dynamic>? metadata,
  }) {
    return ApiResponse._(
      success: false,
      error: error,
      statusCode: statusCode,
      metadata: metadata,
    );
  }
  
  /// Create a loading state response
  factory ApiResponse.loading() {
    return const ApiResponse._(
      success: false,
      message: 'Loading...',
    );
  }
  
  /// Check if response is successful
  bool get isSuccess => success && error == null;
  
  /// Check if response has error
  bool get isError => !success || error != null;
  
  /// Check if response is loading
  bool get isLoading => !success && message == 'Loading...';
  
  /// Get error message or default message
  String getErrorMessage([String defaultMessage = 'Something went wrong']) {
    return error ?? defaultMessage;
  }
  
  /// Transform the data if response is successful
  ApiResponse<R> map<R>(R Function(T) transform) {
    if (isSuccess && data != null) {
      try {
        return ApiResponse.success(
          transform(data as T),
          message: message,
          statusCode: statusCode,
          metadata: metadata,
        );
      } catch (e) {
        return ApiResponse.error(
          'Transformation failed: ${e.toString()}',
          statusCode: statusCode,
        );
      }
    } else {
      return ApiResponse.error(
        error ?? 'No data to transform',
        statusCode: statusCode,
        metadata: metadata,
      );
    }
  }
  
  /// Handle response with callbacks
  R when<R>({
    required R Function(T data) success,
    required R Function(String error) error,
    R Function()? loading,
  }) {
    if (isLoading && loading != null) {
      return loading();
    } else if (isSuccess && data != null) {
      return success(data as T);
    } else {
      return error(getErrorMessage());
    }
  }
  
  /// Convert to JSON (for caching or logging)
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'message': message,
      'error': error,
      'statusCode': statusCode,
      'metadata': metadata,
    };
  }
  
  /// Create from JSON
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse._(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : json['data'],
      message: json['message'],
      error: json['error'],
      statusCode: json['statusCode'],
      metadata: json['metadata'],
    );
  }
  
  @override
  String toString() {
    return 'ApiResponse(success: $success, data: $data, message: $message, error: $error, statusCode: $statusCode)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApiResponse<T> &&
        other.success == success &&
        other.data == data &&
        other.message == message &&
        other.error == error &&
        other.statusCode == statusCode;
  }
  
  @override
  int get hashCode {
    return success.hashCode ^
        data.hashCode ^
        message.hashCode ^
        error.hashCode ^
        statusCode.hashCode;
  }
}