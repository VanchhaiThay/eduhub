import 'package:flutter/material.dart';
import '../class_detail_constants.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String url;
  final int duration;
  final bool isMe;
  final bool isDark;
  final bool isPlaying;
  final VoidCallback onPlayPause;

  const AudioPlayerWidget({
    super.key,
    required this.url,
    required this.duration,
    required this.isMe,
    required this.isDark,
    required this.isPlaying,
    required this.onPlayPause,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _barAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create animations for 4 frequency bars
    _barAnimations = List.generate(
      4,
      (index) => Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            0.6 + (index * 0.1),
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );

    if (widget.isPlaying) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(AudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_animationController.isAnimating) {
      _animationController.repeat();
    } else if (!widget.isPlaying && _animationController.isAnimating) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final displayTime = _formatDuration(widget.duration);
    final textColor = widget.isMe
        ? Colors.white
        : (widget.isDark ? Colors.white : Colors.black87);
    final subtitleColor = widget.isMe
        ? Colors.white70
        : (widget.isDark ? Colors.white70 : Colors.black54);
    final iconColor = widget.isMe
        ? Colors.white
        : ClassDetailConstants.brandColor;
    final frequencyBarColor = widget.isMe
        ? Colors.white
        : ClassDetailConstants.brandColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: widget.onPlayPause,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: frequencyBarColor.withOpacity(0.1),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(
              widget.isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled,
              color: iconColor,
              size: 36,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Animated frequency bars
                  SizedBox(
                    width: 50,
                    height: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (index) {
                        return AnimatedBuilder(
                          animation: _barAnimations[index],
                          builder: (context, child) {
                            return Container(
                              width: 3,
                              height: 16 * _barAnimations[index].value,
                              decoration: BoxDecoration(
                                color: frequencyBarColor.withOpacity(
                                  0.6 + (0.4 * _barAnimations[index].value),
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                displayTime,
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
