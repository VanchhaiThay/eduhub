import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Grade5Page extends StatefulWidget {
  const Grade5Page({super.key});

  @override
  State<Grade5Page> createState() => _Grade5PageState();
}

class _Grade5PageState extends State<Grade5Page> {
  late YoutubePlayerController _controller;
  int _currentPart = 1;

  final List<Map<String, String>> _videos = [
    {'id': 'UZY28ZYm-hM', 'title': 'Lesson 1 - Part 1'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: _videos[0]['id']!,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  void _switchVideo(int part) {
    if (part == _currentPart) return;
    setState(() {
      _currentPart = part;
      _controller.load(_videos[part - 1]['id']!);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Math Grade 5 - Lesson 1')),
      body: Column(
        children: [
          // Fixed Video Player
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.red,
            progressColors: const ProgressBarColors(
              playedColor: Colors.red,
              handleColor: Colors.redAccent,
            ),
          ),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Math Grade 5 - ${_videos[_currentPart - 1]['title']}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Video:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(
                      _videos.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () => _switchVideo(index + 1),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _currentPart == index + 1
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _currentPart == index + 1
                                    ? Colors.blue
                                    : Colors.grey.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _currentPart == index + 1
                                      ? Icons.play_circle_filled
                                      : Icons.play_circle_outline,
                                  color: _currentPart == index + 1
                                      ? Colors.blue
                                      : Colors.grey,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _videos[index]['title']!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _currentPart == index + 1
                                              ? Colors.blue
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _currentPart == index + 1
                                            ? 'Now Playing'
                                            : 'Tap to play',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _currentPart == index + 1
                                              ? Colors.blue.withOpacity(0.7)
                                              : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_currentPart == index + 1)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'ACTIVE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
