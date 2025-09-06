import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/tutorial_provider.dart';
import '../widgets/tutorial_generation_overlay.dart';
import 'tutorial_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _glowController;
  late AnimationController _particleController;
  late Animation<double> _glowAnimation;
  bool _isHovering = false;
  bool _generateImages = true;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _searchFocusNode.unfocus();
      HapticFeedback.lightImpact();
      final tutorialProvider = context.read<TutorialProvider>();
      tutorialProvider.generateTutorial(query, generateImages: _generateImages);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Consumer<TutorialProvider>(
        builder: (context, tutorialProvider, child) {
          return Stack(
            children: [
              // Animated background
              CustomPaint(
                painter: ParticleBackgroundPainter(
                  animation: _particleController,
                ),
                child: Container(),
              ),
              
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    AnimatedOpacity(
                      opacity: _searchFocusNode.hasFocus ? 0.3 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: const Text(
                        'How to Anything',
                        style: TextStyle(
                          // Default Material font is a clean sans-serif
                          color: Colors.white,
                          fontSize: 44,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Glassmorphism search field with glow
                    MouseRegion(
                      onEnter: (_) => setState(() => _isHovering = true),
                      onExit: (_) => setState(() => _isHovering = false),
                      child: AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          return Container(
                            width: math.min(600, MediaQuery.of(context).size.width * 0.85),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00D9FF).withOpacity(_glowAnimation.value * 0.3),
                                  blurRadius: 30,
                                  spreadRadius: _isHovering ? 5 : 0,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          focusNode: _searchFocusNode,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w300,
                                          ),
                                          cursorColor: Colors.cyan,
                                          decoration: const InputDecoration(
                                            hintText: 'What would you like to learn?',
                                            hintStyle: TextStyle(
                                              color: Colors.white30,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w300,
                                            ),
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                            filled: false,
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          textInputAction: TextInputAction.search,
                                          onSubmitted: (_) => _handleSearch(),
                                        ),
                                      ),
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        child: IconButton(
                                          onPressed: _handleSearch,
                                          icon: Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white.withOpacity(_isHovering ? 0.8 : 0.3),
                                          ),
                                          splashRadius: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Minimalist settings/info
                    AnimatedOpacity(
                      opacity: _searchFocusNode.hasFocus ? 0.0 : 0.3,
                      duration: const Duration(milliseconds: 300),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'AI ENHANCED',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.2),
                              fontSize: 10,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: _generateImages ? const Color(0xFF00D9FF) : Colors.white24,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            'PRESS ENTER',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.2),
                              fontSize: 10,
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Subtle settings in corner
              Positioned(
                top: 40,
                right: 40,
                child: AnimatedOpacity(
                  opacity: _searchFocusNode.hasFocus ? 0.0 : 0.3,
                  duration: const Duration(milliseconds: 300),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _generateImages = !_generateImages;
                      });
                      HapticFeedback.selectionClick();
                    },
                    icon: Icon(
                      _generateImages ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                      color: Colors.white.withOpacity(0.3),
                      size: 20,
                    ),
                    tooltip: _generateImages ? 'Images ON' : 'Images OFF',
                  ),
                ),
              ),
              
              // Tutorial generation overlay
              if (tutorialProvider.state == TutorialState.loading)
                TutorialGenerationOverlay(
                  progressMessage: tutorialProvider.progressMessage,
                ),
              
              // Error handling
              if (tutorialProvider.state == TutorialState.error)
                _MinimalErrorOverlay(
                  errorMessage: tutorialProvider.errorMessage,
                  onRetry: () => _handleSearch(),
                  onDismiss: () => tutorialProvider.reset(),
                ),
              
              // Navigation logic
              if (tutorialProvider.state == TutorialState.completed &&
                  tutorialProvider.tutorial != null)
                _NavigationHelper(tutorial: tutorialProvider.tutorial!),
            ],
          );
        },
      ),
    );
  }
}

// Particle background painter for futuristic effect
class ParticleBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Particle> particles = [];
  
  ParticleBackgroundPainter({required this.animation}) : super(repaint: animation) {
    // Initialize particles
    for (int i = 0; i < 50; i++) {
      particles.add(Particle());
    }
  }
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;
    
    // Draw gradient background
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF0A0A0F),
        const Color(0xFF1A1A2E),
      ],
    );
    
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      rect,
      Paint()..shader = gradient.createShader(rect),
    );
    
    // Draw animated particles
    for (var particle in particles) {
      particle.update(animation.value, size);
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.radius,
        paint..color = Colors.cyan.withOpacity(particle.opacity * 0.3),
      );
    }
    
    // Draw connecting lines between nearby particles
    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final distance = (particles[i].x - particles[j].x).abs() + 
                        (particles[i].y - particles[j].y).abs();
        if (distance < 100) {
          canvas.drawLine(
            Offset(particles[i].x, particles[i].y),
            Offset(particles[j].x, particles[j].y),
            paint..color = Colors.cyan.withOpacity(0.01),
          );
        }
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Particle {
  double x = 0;
  double y = 0;
  double vx = 0;
  double vy = 0;
  double radius = 1;
  double opacity = 1;
  
  Particle() {
    reset();
  }
  
  void reset() {
    x = math.Random().nextDouble() * 1000;
    y = math.Random().nextDouble() * 1000;
    vx = (math.Random().nextDouble() - 0.5) * 0.5;
    vy = (math.Random().nextDouble() - 0.5) * 0.5;
    radius = math.Random().nextDouble() * 2 + 0.5;
    opacity = math.Random().nextDouble() * 0.5 + 0.1;
  }
  
  void update(double animationValue, Size size) {
    x += vx;
    y += vy;
    
    if (x < 0 || x > size.width) vx = -vx;
    if (y < 0 || y > size.height) vy = -vy;
    
    opacity = (math.sin(animationValue * math.pi * 2) + 1) / 2 * 0.3 + 0.1;
  }
}

// Minimal error overlay
class _MinimalErrorOverlay extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  const _MinimalErrorOverlay({
    required this.errorMessage,
    required this.onRetry,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Container(
            width: math.min(400, MediaQuery.of(context).size.width * 0.85),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.withOpacity(0.7),
                  size: 40,
                ),
                const SizedBox(height: 20),
                Text(
                  'ERROR',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  errorMessage.length > 100 
                    ? '${errorMessage.substring(0, 100)}...'
                    : errorMessage,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: onDismiss,
                      child: Text(
                        'DISMISS',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          letterSpacing: 2,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    TextButton(
                      onPressed: onRetry,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Colors.cyan.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                      ),
                      child: const Text(
                        'RETRY',
                        style: TextStyle(
                          color: Colors.cyan,
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

// Navigation helper (unchanged)
class _NavigationHelper extends StatefulWidget {
  final dynamic tutorial;
  
  const _NavigationHelper({required this.tutorial});

  @override
  State<_NavigationHelper> createState() => _NavigationHelperState();
}

class _NavigationHelperState extends State<_NavigationHelper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TutorialScreen(tutorial: widget.tutorial),
        ),
      ).then((_) {
        context.read<TutorialProvider>().reset();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
