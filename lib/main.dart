import 'package:flutter/material.dart';
import 'app.dart';
import 'services/http_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await _initializeServices();
  
  runApp(const CdaxApp());
}

Future<void> _initializeServices() async {
  // Initialize HTTP service
  HttpService().initialize();
  
  // Initialize storage service
  await StorageService().initialize();
}


