// Enhanced Video model for Spring Boot backend integration
// Supports JSON serialization and includes metadata

import 'package:flutter/foundation.dart';

@immutable
class Video {
  final String id;
  final String title;
  final String description;
  final String youtubeUrl;
  final int durationSec;
  final int orderIndex; // Order within the module
  final String? thumbnailUrl;
  final bool isLocked;
  final bool isCompleted;

  const Video({
    required this.id,
    required this.title,
    required this.description,
    required this.youtubeUrl,
    required this.durationSec,
    required this.orderIndex,
    this.thumbnailUrl,
    required this.isLocked,
    this.isCompleted = false,
  });

  // JSON serialization for API integration
  factory Video.fromJson(Map<String, dynamic> json) {
    print('🎥 Parsing Video JSON: ${json['title']} (ID: ${json['id']})');
    
    try {
      return Video(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Untitled Video',
        description: json['description']?.toString() ?? '',
        youtubeUrl: json['youtubeUrl']?.toString() ?? json['videoUrl']?.toString() ?? '',
        durationSec: _parseIntSafely(json['durationSec'] ?? json['duration'], 0),
        orderIndex: _parseIntSafely(json['orderIndex'] ?? json['order'], 0),
        thumbnailUrl: json['thumbnailUrl']?.toString(),
        isLocked: _parseBoolSafely(json['isLocked'], false),
        isCompleted: _parseBoolSafely(json['isCompleted'], false),
      );
    } catch (e) {
      print('❌ Error parsing Video JSON: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'youtubeUrl': youtubeUrl,
      'durationSec': durationSec,
      'orderIndex': orderIndex,
      'thumbnailUrl': thumbnailUrl,
      'isLocked': isLocked,
      'isCompleted': isCompleted,
    };
  }

  // Helper method to create video from legacy module data (for fallback)
  factory Video.fromModuleData({
    required String moduleId,
    required String videoUrl,
    int index = 0,
    bool isLocked = false,
  }) {
    return Video(
      id: '${moduleId}_video_$index',
      title: 'Video ${index + 1}',
      description: 'Module video content',
      youtubeUrl: videoUrl,
      durationSec: 600 + index * 120,
      orderIndex: index,
      isLocked: isLocked,
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
  String toString() => 'Video(id: $id, title: $title, youtubeUrl: $youtubeUrl)';
}