// ASSUMPTION: Course model holds modules list; replace with DTO + mapper when backend arrives.

import 'package:flutter/foundation.dart';
import 'module.dart';

@immutable
class Course {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final double progressPercent; // 0..1
  final bool isSubscribed; // Whether course is purchased
  final bool isEnrolled; // Whether user is enrolled in the course
  final List<Module> modules;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.progressPercent,
    required this.isSubscribed,
    this.isEnrolled = false, // Default to not enrolled
    required this.modules,
  });
}


