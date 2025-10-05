import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class AppVideoPlayer extends StatefulWidget {
  const AppVideoPlayer({super.key, required this.videoUrl});
  final String videoUrl;

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  VideoPlayerController? _videoCtrl;
  ChewieController? _chewieCtrl;
  bool _initError = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final video = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await video.initialize();
      final chewie = ChewieController(
        videoPlayerController: video,
        autoPlay: true,
        looping: false,
        allowMuting: true,
        allowFullScreen: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.redAccent,
          bufferedColor: Colors.white70,
          handleColor: Colors.white,
          backgroundColor: Colors.black26,
        ),
      );
      if (!mounted) return;
      setState(() {
        _videoCtrl = video;
        _chewieCtrl = chewie;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _initError = true);
    }
  }

  @override
  void dispose() {
    _chewieCtrl?.dispose();
    _videoCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initError) {
      return const Center(child: Text('Unable to load video'));
    }
    if (_videoCtrl == null || _chewieCtrl == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final aspect = _videoCtrl!.value.isInitialized && _videoCtrl!.value.size.width > 0
        ? _videoCtrl!.value.aspectRatio
        : 16 / 9;
    return AspectRatio(
      aspectRatio: aspect,
      child: Chewie(controller: _chewieCtrl!),
    );
  }
}


