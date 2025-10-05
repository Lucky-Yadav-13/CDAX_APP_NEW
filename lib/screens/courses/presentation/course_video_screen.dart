import 'package:flutter/material.dart';

import '../../../widgets/app_video_player.dart';

class CourseVideoScreen extends StatelessWidget {
  const CourseVideoScreen({super.key, required this.videoUrl});
  final String videoUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Player')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: AppVideoPlayer(videoUrl: videoUrl),
          ),
        ),
      ),
    );
  }
}


