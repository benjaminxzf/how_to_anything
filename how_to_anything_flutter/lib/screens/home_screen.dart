import 'dart:ui';
import 'dart:async';
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

  // Typing guidance state
  final List<String> _suggestions = const [
    'how to fix a dead car battery',
    'how to unclog a sink',
    'how to brew perfect coffee',
    'how to write a resume',
  ];
  String _displayedSuggestion = '';
  int _suggestionIndex = 0;
  int _charIndex = 0;
  bool _isDeletingSuggestion = false;
  Timer? _typingTimer;

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

    _startTypingGuidance();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _typingTimer?.cancel();
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

  // Typing guidance logic
  void _startTypingGuidance() {
    _typingTimer?.cancel();
    _scheduleNextTick(const Duration(milliseconds: 500));
  }

  void _scheduleNextTick([Duration? delay]) {
    _typingTimer?.cancel();
    _typingTimer = Timer(delay ?? const Duration(milliseconds: 80), _tickTypingGuidance);
  }

  void _tickTypingGuidance() {
    if (!mounted) return;
    final current = _suggestions[_suggestionIndex % _suggestions.length];

    setState(() {
      if (!_isDeletingSuggestion) {
        // Typing forward
        if (_charIndex < current.length) {
          _charIndex++;
          _displayedSuggestion = current.substring(0, _charIndex);
          _scheduleNextTick(const Duration(milliseconds: 70));
        } else {
          // Hold before deleting
          _isDeletingSuggestion = true;
          _scheduleNextTick(const Duration(milliseconds: 1200));
        }
      } else {
        // Deleting backward
        if (_charIndex > 0) {
          _charIndex--;
          _displayedSuggestion = current.substring(0, _charIndex);
          _scheduleNextTick(const Duration(milliseconds: 35));
        } else {
          // Move to next suggestion
          _isDeletingSuggestion = false;
          _suggestionIndex = (_suggestionIndex + 1) % _suggestions.length;
          _scheduleNextTick(const Duration(milliseconds: 500));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double inputFontSize = screenWidth < 360
        ? 14
        : (screenWidth < 480
            ? 16
            : (screenWidth < 720
                ? 18
                : 20));
    final double hPad = screenWidth < 360
        ? 16
        : (screenWidth < 480
            ? 20
            : (screenWidth < 720
                ? 24
                : 30));
    final double vPad = screenWidth < 360
        ? 12
        : (screenWidth < 480
            ? 14
            : (screenWidth < 720
                ? 16
                : 20));
    final double arrowIconSize = screenWidth < 360
        ? 18
        : (screenWidth < 480
            ? 20
            : (screenWidth < 720
                ? 22
                : 24));
    final double radius = screenWidth < 360
        ? 22
        : (screenWidth < 480
            ? 26
            : 30);
    final double widthFactor = screenWidth < 360
        ? 0.94
        : (screenWidth < 480
            ? 0.9
            : 0.85);

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
                            width: math.min(600, screenWidth * widthFactor),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(radius),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00D9FF).withOpacity(_glowAnimation.value * 0.3),
                                  blurRadius: 30,
                                  spreadRadius: _isHovering ? 5 : 0,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(radius),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(radius),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Stack(
                                          alignment: Alignment.centerLeft,
                                          children: [
                                            // Real input
                                            TextField(
                                              controller: _searchController,
                                              focusNode: _searchFocusNode,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: inputFontSize,
                                                fontWeight: FontWeight.w300,
                                              ),
                                              cursorColor: Colors.cyan,
                                              decoration: const InputDecoration(
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
                                            // Typing guidance overlay (shows only when empty & unfocused)
                                            if (!_searchFocusNode.hasFocus && _searchController.text.isEmpty)
                                              IgnorePointer(
                                                child: AnimatedOpacity(
                                                  opacity: 0.35,
                                                  duration: const Duration(milliseconds: 250),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          _displayedSuggestion,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.clip,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: inputFontSize,
                                                            fontWeight: FontWeight.w300,
                                                          ),
                                                        ),
                                                      ),
                                                      // Subtle blinking caret
                                                      Container(
                                                        width: 2,
                                                        height: inputFontSize,
                                                        margin: const EdgeInsets.only(left: 2),
                                                        color: Colors.white.withOpacity(((((
                                                                  _glowAnimation.value - 0.5) * 2)
                                                              .clamp(0.0, 1.0)) as num)
                                                              .toDouble()),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
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
                                          iconSize: arrowIconSize,
                                          splashRadius: arrowIconSize + 4,
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
