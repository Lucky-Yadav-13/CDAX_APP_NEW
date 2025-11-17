/// Authentication Response Model
/// Represents the response from authentication endpoints
class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final String? refreshToken;
  final UserModel? user;
  final Map<String, dynamic>? additionalData;
  
  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.refreshToken,
    this.user,
    this.additionalData,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? json['status'] == 'success' ?? false,
      message: json['message'] ?? json['msg'] ?? '',
      token: json['token'] ?? json['accessToken'],
      refreshToken: json['refreshToken'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      additionalData: json['data'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'refreshToken': refreshToken,
      'user': user?.toJson(),
      'data': additionalData,
    };
  }
  
  @override
  String toString() {
    return 'AuthResponse(success: $success, message: $message, hasToken: ${token != null})';
  }
}

/// Simple user model for authentication responses
class UserModel {
  final String? id;
  final String email;
  final String firstName;
  final String lastName;
  final String? mobile;
  final bool isSubscribed;
  final Map<String, dynamic>? additionalData;
  
  UserModel({
    this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.mobile,
    this.isSubscribed = false,
    this.additionalData,
  });
  
  String get fullName => '$firstName $lastName'.trim();
  String get displayName => fullName.isNotEmpty ? fullName : email;
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      mobile: json['mobile']?.toString(),
      isSubscribed: json['subscribed'] ?? json['isSubscribed'] ?? false,
      additionalData: json,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'mobile': mobile,
      'subscribed': isSubscribed,
      ...?additionalData,
    };
  }
  
  @override
  String toString() {
    return 'UserModel(email: $email, fullName: $fullName)';
  }
}