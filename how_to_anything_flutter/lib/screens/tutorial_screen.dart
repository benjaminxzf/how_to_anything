import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:provider/provider.dart';
import '../models/tutorial.dart';
import '../services/tutorial_provider.dart';
import '../widgets/tutorial_step_card.dart';
import '../widgets/tutorial_overview_card.dart';

class TutorialScreen extends StatefulWidget {
  final Tutorial tutorial;

  const TutorialScreen({Key? key, required this.tutorial}) : super(key: key);

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> with TickerProviderStateMixin {
  final SwiperController _swiperController = SwiperController();
  late AnimationController _backgroundAnimationController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _swiperController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _onIndexChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to provider for tutorial updates (especially images)
    return Consumer<TutorialProvider>(
      builder: (context, tutorialProvider, child) {
        // Use the tutorial from provider if available, otherwise use the initial one
        final tutorial = tutorialProvider.tutorial ?? widget.tutorial;
        final totalCards = tutorial.steps.length + 1;
        
        return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _backgroundAnimationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      -1 + 2 * _backgroundAnimationController.value,
                      -1 + 2 * _backgroundAnimationController.value,
                    ),
                    end: Alignment(
                      1 - 2 * _backgroundAnimationController.value,
                      1 - 2 * _backgroundAnimationController.value,
                    ),
                    colors: const [
                      Color(0xFF0A0A0F),
                      Color(0xFF1A1A2E),
                      Color(0xFF0A0A0F),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Minimal header
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width < 600 ? 12 : 20, 
                    vertical: 16
                  ),
                  child: Row(
                    children: [
                      // Back button
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white.withOpacity(0.6),
                          size: 20,
                        ),
                      ),
                      
                      // Step indicator
                      Expanded(
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _currentIndex == 0
                                  ? 'OVERVIEW'
                                  : 'STEP $_currentIndex OF ${widget.tutorial.steps.length}',
                              key: ValueKey(_currentIndex),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 10,
                                letterSpacing: 3,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Close button
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: Colors.white.withOpacity(0.6),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Tutorial cards
                Expanded(
                  child: Swiper(
                    controller: _swiperController,
                    itemCount: totalCards,
                    onIndexChanged: _onIndexChanged,
                    duration: 400, // Slower animation
                    curve: Curves.easeInOut, // Smoother curve
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Overview card
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width < 600 ? 2 : 4, 
                            vertical: 10
                          ),
                          child: TutorialOverviewCard(
                            tutorial: tutorial,
                            isActive: _currentIndex == 0,
                          ),
                        );
                      } else {
                        // Step cards
                        final step = tutorial.steps[index - 1];
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width < 600 ? 2 : 4, 
                            vertical: 10
                          ),
                          child: TutorialStepCard(
                            key: ValueKey('step_${index - 1}_${step.imageUrl != null}'), // Force rebuild when image changes
                            step: step,
                            isActive: index == _currentIndex,
                          ),
                        );
                      }
                    },
                    viewportFraction: 0.85,
                    scale: 0.9,
                    loop: false,
                    pagination: null, // We'll use custom dots below
                    control: null, // Remove default controls
                    autoplay: false,
                    physics: const ClampingScrollPhysics(), // Better physics for images
                  ),
                ),
                
              ],
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  void _showCompletionDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 60,
                  color: Colors.green.withOpacity(0.8),
                ),
                const SizedBox(height: 24),
                Text(
                  'TUTORIAL COMPLETE',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.tutorial.title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context).pop(); // Go back to home
                      },
                      child: Text(
                        'NEW TUTORIAL',
                        style: TextStyle(
                          color: Colors.cyan.withOpacity(0.8),
                          letterSpacing: 2,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Colors.green.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        'DONE',
                        style: TextStyle(
                          color: Colors.green.withOpacity(0.8),
                          letterSpacing: 2,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}