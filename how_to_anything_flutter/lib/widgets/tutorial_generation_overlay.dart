import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TutorialGenerationOverlay extends StatelessWidget {
  final String progressMessage;

  const TutorialGenerationOverlay({
    Key? key,
    required this.progressMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 15,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon
              Shimmer.fromColors(
                baseColor: const Color(0xFF6366F1),
                highlightColor: const Color(0xFF8B5CF6),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 64,
                  color: Color(0xFF6366F1),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              const Text(
                'Generating Tutorial',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Progress message
              Text(
                progressMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Loading indicator
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Info text
              Text(
                'This may take 2-3 minutes...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}