// Storage Service
// Handles local storage operations (In-memory for now, replace with SharedPreferences later)

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();
  
  // In-memory storage (replace with SharedPreferences later)
  final Map<String, dynamic> _storage = {};
  
  // Initialize storage service
  Future<void> initialize() async {
    // Initialize in-memory storage
    // TODO: Replace with SharedPreferences.getInstance() when dependency is added
  }
  
  // Get storage instance
  Map<String, dynamic> get prefs {
    return _storage;
  }
  
  // String operations
  Future<bool> setString(String key, String value) async {
    _storage[key] = value;
    return true;
  }
  
  String? getString(String key) {
    return _storage[key] as String?;
  }
  
  // Integer operations
  Future<bool> setInt(String key, int value) async {
    _storage[key] = value;
    return true;
  }
  
  int? getInt(String key) {
    return _storage[key] as int?;
  }
  
  // Double operations
  Future<bool> setDouble(String key, double value) async {
    _storage[key] = value;
    return true;
  }
  
  double? getDouble(String key) {
    return _storage[key] as double?;
  }
  
  // Boolean operations
  Future<bool> setBool(String key, bool value) async {
    _storage[key] = value;
    return true;
  }
  
  bool? getBool(String key) {
    return _storage[key] as bool?;
  }
  
  // String list operations
  Future<bool> setStringList(String key, List<String> value) async {
    _storage[key] = value;
    return true;
  }
  
  List<String>? getStringList(String key) {
    return _storage[key] as List<String>?;
  }
  
  // Remove key
  Future<bool> remove(String key) async {
    _storage.remove(key);
    return true;
  }
  
  // Clear all data
  Future<bool> clear() async {
    _storage.clear();
    return true;
  }
  
  // Check if key exists
  bool containsKey(String key) {
    return _storage.containsKey(key);
  }
  
  // Get all keys
  Set<String> getKeys() {
    return _storage.keys.toSet();
  }
}