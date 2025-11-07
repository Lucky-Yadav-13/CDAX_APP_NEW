// Enhanced Module model for Spring Boot backend integration
// Supports JSON serialization and includes video list

import 'package:flutter/foundation.dart';
import 'video.dart';

@immutable
class Module {
  final String id;
  final String title;
  final String description;
  final int durationSec;
  final bool isLocked;
  final int orderIndex; // Order within the course
  final List<Video> videos; // List of videos in this module
  
  // Legacy support - first video URL for backward compatibility
  String get videoUrl => videos.isNotEmpty ? videos.first.youtubeUrl : '';

  const Module({
    required this.id,
    required this.title,
    this.description = '',
    required this.durationSec,
    required this.isLocked,
    this.orderIndex = 0,
    this.videos = const [],
  });

  // JSON serialization for API integration
  factory Module.fromJson(Map<String, dynamic> json) {
    print('📚 Parsing Module JSON: ${json['title']} (ID: ${json['id']})');
    
    try {
      // Parse videos list
      List<Video> videosList = [];
      if (json['videos'] != null && json['videos'] is List) {
        videosList = (json['videos'] as List)
            .map((videoJson) => Video.fromJson(videoJson))
            .toList();
        print('   ├─ Found ${videosList.length} videos in module');
      }

      return Module(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Untitled Module',
        description: json['description']?.toString() ?? '',
        durationSec: _parseIntSafely(json['durationSec'] ?? json['duration'], 0),
        isLocked: _parseBoolSafely(json['isLocked'], false),
        orderIndex: _parseIntSafely(json['orderIndex'] ?? json['order'], 0),
        videos: videosList,
      );
    } catch (e) {
      print('❌ Error parsing Module JSON: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'durationSec': durationSec,
      'isLocked': isLocked,
      'orderIndex': orderIndex,
      'videos': videos.map((video) => video.toJson()).toList(),
    };
  }

  // Legacy constructor for backward compatibility with existing mock data
  factory Module.legacy({
    required String id,
    required String title,
    required int durationSec,
    required bool isLocked,
    required String videoUrl,
  }) {
    print('🔄 Creating legacy Module: $title with single video');
    
    return Module(
      id: id,
      title: title,
      durationSec: durationSec,
      isLocked: isLocked,
      videos: [
        Video.fromModuleData(
          moduleId: id,
          videoUrl: videoUrl,
          isLocked: isLocked,
        ),
      ],
    );
  }

  // Utility methods for safe parsing
  static int _parseIntSafely(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    if (value is double) return value.toInt();
    return defaultValue;
  }

  static bool _parseBoolSafely(dynamic value, bool defaultValue) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value == 1;
    return defaultValue;
  }

  @override
  String toString() => 'Module(id: $id, title: $title, videos: ${videos.length})';
}


