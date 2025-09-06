import 'dart:ui';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/tutorial_step.dart';

class _BananaLoadingPlaceholder extends StatefulWidget {
  final String imagePrompt;

  const _BananaLoadingPlaceholder({
    Key? key,
    required this.imagePrompt,
  }) : super(key: key);

  @override
  State<_BananaLoadingPlaceholder> createState() => _BananaLoadingPlaceholderState();
}

class _BananaLoadingPlaceholderState extends State<_BananaLoadingPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value,
                child: Text(
                  '🍌',
                  style: TextStyle(fontSize: 60),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Loading dots animation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  final value = (_animationController.value + index * 0.2) % 1.0;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.cyan.withOpacity(0.3 + value * 0.5),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            'GENERATING IMAGE',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 10,
              letterSpacing: 3,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width < 600 ? 12 : 20
            ),
            child: Text(
              widget.imagePrompt.length > 60 
                ? '${widget.imagePrompt.substring(0, 60)}...'
                : widget.imagePrompt,
              style: TextStyle(
                color: Colors.white.withOpacity(0.2),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class TutorialStepCard extends StatefulWidget {
  final TutorialStep step;
  final bool isActive;

  const TutorialStepCard({
    Key? key,
    required this.step,
    required this.isActive,
  }) : super(key: key);

  @override
  State<TutorialStepCard> createState() => _TutorialStepCardState();
}

class _TutorialStepCardState extends State<TutorialStepCard> 
    with AutomaticKeepAliveClientMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    if (widget.step.audioUrl == null) return;
    
    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
        return;
      }

      final audioDataUrl = widget.step.audioUrl!;
      if (audioDataUrl.startsWith('data:audio/wav;base64,')) {
        final base64String = audioDataUrl.substring('data:audio/wav;base64,'.length);
        final audioBytes = base64Decode(base64String);
        await _audioPlayer.play(BytesSource(audioBytes));
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  @override
  bool get wantKeepAlive => true; // Keep card alive during swipe
  
  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: widget.isActive 
                    ? Colors.cyan.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: widget.isActive
                  ? [
                      BoxShadow(
                        color: Colors.cyan.withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step header
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.cyan.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.cyan.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${widget.step.stepNumber}',
                            style: TextStyle(
                              color: Colors.cyan.withOpacity(0.9),
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.step.title.toUpperCase(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 2,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            if (widget.step.estimatedTime != null)
                              Text(
                                widget.step.estimatedTime!.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 1,
                                  color: Colors.white.withOpacity(0.4),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (widget.step.audioUrl != null)
                        IconButton(
                          onPressed: _playAudio,
                          icon: Icon(
                            _isPlaying ? Icons.pause_circle : Icons.play_circle,
                            color: Colors.cyan.withOpacity(0.6),
                            size: 28,
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Step image with full width and dynamic height
                  if (widget.step.imageUrl != null && widget.step.imageUrl!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        // Wrap in IntrinsicHeight to maintain aspect ratio
                        child: IntrinsicHeight(
                          child: _buildImage(),
                        ),
                      ),
                    )
                  else
                    _BananaLoadingPlaceholder(
                      imagePrompt: widget.step.imagePrompt,
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Step description
                  Text(
                    widget.step.description,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  
                  // Tools needed for this step
                  if (widget.step.toolsNeeded != null && 
                      widget.step.toolsNeeded!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildInfoSection(
                      icon: Icons.build_outlined,
                      title: 'TOOLS',
                      items: widget.step.toolsNeeded!,
                      color: Colors.blue,
                    ),
                  ],
                  
                  // Tips
                  if (widget.step.tips != null && widget.step.tips!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildInfoSection(
                      icon: Icons.lightbulb_outline,
                      title: 'TIPS',
                      items: widget.step.tips!,
                      color: Colors.green,
                    ),
                  ],
                  
                  // Warnings
                  if (widget.step.warnings != null && widget.step.warnings!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildInfoSection(
                      icon: Icons.warning_amber_outlined,
                      title: 'WARNINGS',
                      items: widget.step.warnings!,
                      color: Colors.orange,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final imageUrl = widget.step.imageUrl!;
    
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64String = imageUrl.split(',')[1];
        final imageBytes = base64Decode(base64String);
        
        // Wrap in RepaintBoundary to prevent disposal during animation
        return RepaintBoundary(
          child: Image.memory(
            imageBytes,
            fit: BoxFit.fitWidth,
            width: double.infinity,
            gaplessPlayback: true, // Prevents flicker during rebuild
            cacheWidth: 1200, // Cache at reasonable resolution
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.black.withOpacity(0.2),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image_outlined, 
                        size: 40, 
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'IMAGE LOAD ERROR',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      } catch (e) {
        return Container(
          height: 200,
          color: Colors.black.withOpacity(0.2),
          child: Center(
            child: Icon(
              Icons.error_outline,
              size: 40,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        );
      }
    } else {
      return Container(
        height: 200,
        color: Colors.black.withOpacity(0.2),
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 40,
            color: Colors.white.withOpacity(0.3),
          ),
        ),
      );
    }
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required List<String> items,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color.withOpacity(0.8),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w400,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.6),
                        height: 1.4,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}