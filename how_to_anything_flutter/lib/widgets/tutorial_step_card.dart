import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../models/tutorial_step.dart';

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

class _TutorialStepCardState extends State<TutorialStepCard> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;

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
      setState(() {
        _isLoading = true;
      });

      if (_isPlaying) {
        await _audioPlayer.stop();
        return;
      }

      // Parse data URL and create audio source
      final audioDataUrl = widget.step.audioUrl!;
      if (audioDataUrl.startsWith('data:audio/wav;base64,')) {
        final base64String = audioDataUrl.substring('data:audio/wav;base64,'.length);
        final audioBytes = base64Decode(base64String);
        
        await _audioPlayer.play(BytesSource(audioBytes));
      }
    } catch (e) {
      print('Error playing audio: $e');
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not play audio: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Card(
        elevation: widget.isActive ? 8 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: widget.isActive
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      const Color(0xFF6366F1).withOpacity(0.02),
                    ],
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${widget.step.stepNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
                          widget.step.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        if (widget.step.estimatedTime != null)
                          Text(
                            '⏱️ ${widget.step.estimatedTime}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Audio control button
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: widget.step.audioUrl != null ? _playAudio : null,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: widget.step.audioUrl != null
                                  ? const Color(0xFF6366F1)
                                  : Colors.grey,
                            ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Step image
              if (widget.step.imageUrl != null && widget.step.imageUrl!.isNotEmpty)
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildImage(),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'AI Image',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.step.imagePrompt.length > 80 
                          ? '${widget.step.imagePrompt.substring(0, 80)}...'
                          : widget.step.imagePrompt,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 20),
              
              // Step description
              Text(
                widget.step.description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Color(0xFF374151),
                ),
              ),
              
              // Tools needed for this step
              if (widget.step.toolsNeeded != null && 
                  widget.step.toolsNeeded!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildInfoSection(
                  icon: Icons.build_outlined,
                  title: 'Tools needed:',
                  items: widget.step.toolsNeeded!,
                  color: Colors.blue,
                ),
              ],
              
              // Tips
              if (widget.step.tips != null && widget.step.tips!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildInfoSection(
                  icon: Icons.lightbulb_outline,
                  title: 'Tips:',
                  items: widget.step.tips!,
                  color: Colors.green,
                ),
              ],
              
              // Warnings
              if (widget.step.warnings != null && widget.step.warnings!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildInfoSection(
                  icon: Icons.warning_amber_outlined,
                  title: 'Warnings:',
                  items: widget.step.warnings!,
                  color: Colors.orange,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final imageUrl = widget.step.imageUrl!;
    
    if (imageUrl.startsWith('data:image')) {
      // Handle data URL
      try {
        final base64String = imageUrl.split(',')[1];
        final imageBytes = base64Decode(base64String);
        return Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Failed to load image', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            );
          },
        );
      } catch (e) {
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('Invalid image data', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        );
      }
    } else {
      // Handle regular URL (future enhancement)
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('Image format not supported', style: TextStyle(color: Colors.grey)),
            ],
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
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14,
                        color: color.withOpacity(0.8),
                        height: 1.4,
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