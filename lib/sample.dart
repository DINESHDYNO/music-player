import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';


class VideoApp extends StatefulWidget {
  const VideoApp({super.key});

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;
  final videolink = 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(videolink))..addListener(() { })..setLooping(true)
      ..initialize().then((_) => setState((){}));
  }

  @override
  Widget build(BuildContext context) {
    final isMuted = _controller.value.volume == 0;
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Play'),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? Column(
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
            SizedBox(height: 14,),
            VideoProgressIndicator(
                _controller, allowScrubbing: true),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause() : _controller.play();}); },
                  icon: Icon(_controller.value.isPlaying ? Icons.play_arrow : Icons.pause, size: 30,),),
                IconButton(
                    onPressed: ()  {
                      setState(() {
                        _controller.setVolume(isMuted ? 1 : 0);
                      });
                    },
                    icon: Icon(isMuted ? Icons.volume_mute : Icons.volume_up))
              ],
            )
          ],
        ) : Container(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

