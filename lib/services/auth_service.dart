// Authentication Service
// Handles user authentication with Spring Boot backend
import 'dart:convert';
import '../constants/api_endpoints.dart';
import '../models/auth/auth_response_model.dart';
import '../core/user_manager.dart';
import 'http_service.dart';
import 'storage_service.dart';

class AuthService {
  final HttpService _httpService = HttpService();
  final StorageService _storageService = StorageService();
  
  // Login user
  Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    // Input validation
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return ApiResponse.error('Email and password are required');
    }
    
    try {
      final response = await _httpService.post<AuthResponse>(
        ApiEndpoints.login,
        (data) => AuthResponse.fromJson(data),
        body: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.isSuccess && response.data != null) {
        final authResponse = response.data!;
        
        // Store user session in UserManager
        await UserManager.setEmail(email);
        
        // Store tokens and user data if available
        if (authResponse.token != null && authResponse.token!.isNotEmpty) {
          await _storageService.setString('auth_token', authResponse.token!);
          _httpService.setAuthToken(authResponse.token!);
        }
        if (authResponse.refreshToken != null && authResponse.refreshToken!.isNotEmpty) {
          await _storageService.setString('refresh_token', authResponse.refreshToken!);
        }
        if (authResponse.user != null) {
          await _storageService.setString('user_data', jsonEncode(authResponse.user!.toJson()));
        }
      }
      
      return response;
    } catch (e) {
      return ApiResponse.error('Login failed: ${e.toString()}');
    }
  }
  
  // Register user
  Future<ApiResponse<AuthResponse>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String password,
    required String confirmPassword,
  }) async {
    // Input validation
    if (firstName.trim().isEmpty || lastName.trim().isEmpty || 
        email.trim().isEmpty || mobile.trim().isEmpty || 
        password.trim().isEmpty || confirmPassword.trim().isEmpty) {
      return ApiResponse.error('All fields are required');
    }
    
    if (password != confirmPassword) {
      return ApiResponse.error('Passwords do not match');
    }
    
    try {
      final response = await _httpService.post<AuthResponse>(
        ApiEndpoints.register,
        (data) => AuthResponse.fromJson(data),
        body: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'mobile': mobile,
          'password': password,
          'cpassword': confirmPassword,
        },
      );
      
      if (response.isSuccess && response.data != null) {
        final authResponse = response.data!;
        
        // Store tokens and user data if available
        if (authResponse.token != null && authResponse.token!.isNotEmpty) {
          await _storageService.setString('auth_token', authResponse.token!);
          _httpService.setAuthToken(authResponse.token!);
        }
        if (authResponse.refreshToken != null && authResponse.refreshToken!.isNotEmpty) {
          await _storageService.setString('refresh_token', authResponse.refreshToken!);
        }
        if (authResponse.user != null) {
          await _storageService.setString('user_data', jsonEncode(authResponse.user!.toJson()));
        }
      }
      
      return response;
    } catch (e) {
      return ApiResponse.error('Registration failed: ${e.toString()}');
    }
  }
  
  // Logout user
  Future<ApiResponse<Map<String, dynamic>>> logout() async {
    try {
      final response = await _httpService.post<Map<String, dynamic>>(
        ApiEndpoints.logout,
        (data) => data as Map<String, dynamic>,
      );
      
      // Clear local storage regardless of API response
      await _clearLocalData();
      
      return response;
    } catch (e) {
      // Clear local data even if API call fails
      await _clearLocalData();
      return ApiResponse.error('Logout failed: ${e.toString()}');
    }
  }

  // Get user's first name by email
  Future<String?> getFirstName(String email) async {
    try {
      final response = await _httpService.get<Map<String, dynamic>>(
        '/auth/firstName',
        (data) => data as Map<String, dynamic>,
        queryParams: {'email': email},
      );
      
      if (response.isSuccess && response.data != null) {
        return response.data!['firstName']?.toString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Get user details by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final response = await _httpService.get<Map<String, dynamic>>(
        '/auth/getUserByEmail',
        (data) => data as Map<String, dynamic>,
        queryParams: {'email': email},
      );
      
      if (response.isSuccess && response.data != null && response.data!['status'] == 'success') {
        return UserModel.fromJson(response.data!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Refresh token
  Future<ApiResponse<AuthResponse>> refreshToken() async {
    try {
      final refreshToken = _storageService.getString('refresh_token');
      if (refreshToken == null) {
        return ApiResponse.error('No refresh token found');
      }
      
      final response = await _httpService.post<AuthResponse>(
        ApiEndpoints.refreshToken,
        (data) => AuthResponse.fromJson(data),
        body: {
          'refreshToken': refreshToken,
        },
      );
      
      if (response.isSuccess && response.data != null) {
        final authResponse = response.data!;
        
        // Update stored tokens
        if (authResponse.token != null && authResponse.token!.isNotEmpty) {
          await _storageService.setString('auth_token', authResponse.token!);
          _httpService.setAuthToken(authResponse.token!);
        }
        if (authResponse.refreshToken != null && authResponse.refreshToken!.isNotEmpty) {
          await _storageService.setString('refresh_token', authResponse.refreshToken!);
        }
      }
      
      return response;
    } catch (e) {
      return ApiResponse.error('Token refresh failed: ${e.toString()}');
    }
  }
  
  // Forgot password
  Future<ApiResponse<Map<String, dynamic>>> forgotPassword({
    required String email,
  }) async {
    try {
      return await _httpService.post<Map<String, dynamic>>(
        ApiEndpoints.forgotPassword,
        (data) => data as Map<String, dynamic>,
        body: {
          'email': email,
        },
      );
    } catch (e) {
      return ApiResponse.error('Forgot password failed: ${e.toString()}');
    }
  }
  
  // Reset password
  Future<ApiResponse<Map<String, dynamic>>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      return await _httpService.post<Map<String, dynamic>>(
        ApiEndpoints.resetPassword,
        (data) => data as Map<String, dynamic>,
        body: {
          'token': token,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      return ApiResponse.error('Password reset failed: ${e.toString()}');
    }
  }
  
  // Change password
  Future<ApiResponse<Map<String, dynamic>>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      return await _httpService.post<Map<String, dynamic>>(
        ApiEndpoints.changePassword,
        (data) => data as Map<String, dynamic>,
        body: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      return ApiResponse.error('Password change failed: ${e.toString()}');
    }
  }
  
  // Verify email
  Future<ApiResponse<Map<String, dynamic>>> verifyEmail({
    required String token,
  }) async {
    try {
      return await _httpService.post<Map<String, dynamic>>(
        ApiEndpoints.verifyEmail,
        (data) => data as Map<String, dynamic>,
        body: {
          'token': token,
        },
      );
    } catch (e) {
      return ApiResponse.error('Email verification failed: ${e.toString()}');
    }
  }
  
  // Check if user is authenticated (using UserManager)
  Future<bool> isAuthenticated() async {
    final email = await UserManager.getEmail();
    return email != null && email.isNotEmpty;
  }
  
  // Get current user from storage
  Future<UserModel?> getCurrentUser() async {
    try {
      final userDataString = _storageService.getString('user_data');
      if (userDataString != null) {
        // Parse JSON string back to UserModel
        final Map<String, dynamic> userData = json.decode(userDataString);
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Get current user email
  Future<String?> getCurrentUserEmail() async {
    return await UserManager.getEmail();
  }
  
  // Initialize auth service (call this at app startup)
  Future<void> initialize() async {
    final token = _storageService.getString('auth_token');
    if (token != null) {
      _httpService.setAuthToken(token);
    }
  }
  
  // Clear local authentication data
  Future<void> _clearLocalData() async {
    await UserManager.clearSession();
    await _storageService.remove('auth_token');
    await _storageService.remove('refresh_token');
    await _storageService.remove('user_data');
    _httpService.clearAuthToken();
  }
}
