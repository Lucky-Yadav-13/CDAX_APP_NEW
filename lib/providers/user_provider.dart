/// User Provider
/// Manages user state and user-related operations
import 'package:flutter/foundation.dart';
import '../models/auth/auth_response_model.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  
  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  
  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Set error
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
  
  // Set current user
  void setCurrentUser(UserModel? user) {
    _currentUser = user;
    _error = null;
    notifyListeners();
  }
  
  // Initialize authentication state
  Future<void> initialize() async {
    _setLoading(true);
    _isAuthenticated = await _authService.isAuthenticated();
    if (_isAuthenticated) {
      _currentUser = await _authService.getCurrentUser();
    }
    _setLoading(false);
  }
  
  // Load current user
  Future<void> loadCurrentUser() async {
    _setLoading(true);
    _setError(null);
    
    try {
      _currentUser = await _authService.getCurrentUser();
      _isAuthenticated = _currentUser != null;
    } catch (e) {
      _setError('Failed to load user: ${e.toString()}');
      _isAuthenticated = false;
    }
    
    _setLoading(false);
  }
  
  // Login user
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    
    final response = await _authService.login(email: email, password: password);
    
    if (response.isSuccess && response.data != null && response.data!.success) {
      _currentUser = response.data!.user;
      _isAuthenticated = true;
      _setLoading(false);
      return true;
    } else {
      _setError(response.data?.message ?? response.error ?? 'Login failed');
      _isAuthenticated = false;
      _setLoading(false);
      return false;
    }
  }
  
  // Register user
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String password,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    _setError(null);
    
    final response = await _authService.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      mobile: mobile,
      password: password,
      confirmPassword: confirmPassword,
    );
    
    if (response.isSuccess && response.data != null && response.data!.success) {
      _setLoading(false);
      return true;
    } else {
      _setError(response.data?.message ?? response.error ?? 'Registration failed');
      _setLoading(false);
      return false;
    }
  }
  
  // Logout user
  Future<void> logout() async {
    _setLoading(true);
    await _authService.logout();
    _currentUser = null;
    _isAuthenticated = false;
    _error = null;
    _setLoading(false);
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}