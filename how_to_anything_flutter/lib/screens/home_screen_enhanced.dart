import 'dart:ui';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/tutorial_provider.dart';
import '../widgets/tutorial_generation_overlay.dart';
import '../widgets/particle_field.dart';
import '../widgets/liquid_search_bar.dart';
import '../utils/animation_utils.dart';
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
  late AnimationController _titleController;
  late AnimationController _glitchController;
  late AnimationController _parallaxController;
  late AnimationController _floatController;
  late AnimationController _morphController;
  
  late Animation<double> _glowAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _glitchAnimation;
  late Animation<Offset> _parallaxAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _morphAnimation;
  
  bool _isHovering = false;
  bool _generateImages = true;
  Offset _mousePosition = Offset.zero;

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
    _initializeAnimations();
    _startTypingGuidance();
    _startAnimations();
  }
  
  void _initializeAnimations() {
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _glitchController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
    
    _parallaxController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _morphController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
    
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _titleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: const SpringCurve(damping: 12, stiffness: 100),
    ));
    
    _glitchAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glitchController,
      curve: const GlitchCurve(glitches: 5, intensity: 0.05),
    ));
    
    _parallaxAnimation = Tween<Offset>(
      begin: const Offset(-0.05, -0.05),
      end: const Offset(0.05, 0.05),
    ).animate(CurvedAnimation(
      parent: _parallaxController,
      curve: Curves.easeInOut,
    ));
    
    _floatAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    
    _morphAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: const WaveCurve(frequency: 2, amplitude: 0.1),
    ));
  }
  
  void _startAnimations() {
    _titleController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _glowController.dispose();
    _titleController.dispose();
    _glitchController.dispose();
    _parallaxController.dispose();
    _floatController.dispose();
    _morphController.dispose();
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
  
  Widget _buildAnimatedBadge(String text, Color color, int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 1000 + delay),
      curve: const ElasticCurve(period: 0.4, amplitude: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color,
                width: 1,
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 10,
                letterSpacing: 3,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: MouseRegion(
        onHover: (event) {
          setState(() {
            _mousePosition = event.position;
          });
        },
        child: Consumer<TutorialProvider>(
          builder: (context, tutorialProvider, child) {
            return Stack(
              children: [
                // Advanced particle field background
                const Positioned.fill(
                  child: ParticleField(
                    particleCount: 80,
                    enableFlocking: true,
                    enableGravity: true,
                    enableMouseInteraction: true,
                    particleColor: Colors.cyan,
                    connectionDistance: 120,
                  ),
                ),
                
                // Main content with parallax
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _parallaxAnimation,
                    _floatAnimation,
                  ]),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        _parallaxAnimation.value.dx * 50,
                        _parallaxAnimation.value.dy * 50 + _floatAnimation.value,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Morphing title with glitch effect
                            AnimatedBuilder(
                              animation: Listenable.merge([
                                _titleAnimation,
                                _glitchAnimation,
                                _morphAnimation,
                                _searchFocusNode,
                              ]),
                              builder: (context, child) {
                                final glitchOffset = math.sin(_glitchAnimation.value * math.pi * 10) * 2;
                                final morphScale = 1.0 + math.sin(_morphAnimation.value * math.pi * 2) * 0.05;
                                
                                return Transform(
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..rotateX(_titleAnimation.value * 0.02)
                                    ..rotateY(math.sin(_glitchAnimation.value * math.pi * 2) * 0.01)
                                    ..scale(
                                      morphScale * (0.8 + _titleAnimation.value * 0.2),
                                      morphScale * (0.8 + _titleAnimation.value * 0.2),
                                    )
                                    ..translate(glitchOffset, 0),
                                  alignment: Alignment.center,
                                  child: Stack(
                                    children: [
                                      // Glitch layers
                                      if (_glitchAnimation.value > 0.95)
                                        Transform.translate(
                                          offset: const Offset(-2, -2),
                                          child: Text(
                                            'How to Anything',
                                            style: TextStyle(
                                              color: Colors.red.withOpacity(0.3),
                                              fontSize: 44 + _titleAnimation.value * 4,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5 + _titleAnimation.value * 2,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      if (_glitchAnimation.value > 0.95)
                                        Transform.translate(
                                          offset: const Offset(2, 2),
                                          child: Text(
                                            'How to Anything',
                                            style: TextStyle(
                                              color: Colors.blue.withOpacity(0.3),
                                              fontSize: 44 + _titleAnimation.value * 4,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5 + _titleAnimation.value * 2,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      // Main title with gradient
                                      ShaderMask(
                                        shaderCallback: (bounds) {
                                          return LinearGradient(
                                            begin: Alignment(
                                              -1 + _morphAnimation.value * 2,
                                              0,
                                            ),
                                            end: Alignment(
                                              0 + _morphAnimation.value * 2,
                                              0,
                                            ),
                                            colors: [
                                              Colors.purple,
                                              Colors.cyan,
                                              Colors.white,
                                              Colors.cyan,
                                              Colors.purple,
                                            ],
                                            stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                                          ).createShader(bounds);
                                        },
                                        child: AnimatedOpacity(
                                          opacity: _searchFocusNode.hasFocus ? 0.3 : 1.0,
                                          duration: const Duration(milliseconds: 300),
                                          child: Text(
                                            'How to Anything',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 44 + _titleAnimation.value * 4,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5 + _titleAnimation.value * 2,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // Liquid motion search bar
                            LiquidSearchBar(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              onSearch: _handleSearch,
                              hintText: _displayedSuggestion,
                              width: math.min(600, screenWidth * 0.85),
                            ),
                            
                            const SizedBox(height: 60),
                            
                            // Animated info badges with spring physics
                            AnimatedBuilder(
                              animation: _titleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 1.0 + math.sin(_titleAnimation.value * math.pi) * 0.1,
                                  child: AnimatedOpacity(
                                    opacity: _searchFocusNode.hasFocus ? 0.0 : 0.3,
                                    duration: const Duration(milliseconds: 300),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _buildAnimatedBadge(
                                          'AI ENHANCED',
                                          Colors.cyan.withOpacity(0.2),
                                          0,
                                        ),
                                        const SizedBox(width: 20),
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: _generateImages ? const Color(0xFF00D9FF) : Colors.white24,
                                            shape: BoxShape.circle,
                                            boxShadow: _generateImages ? [
                                              BoxShadow(
                                                color: Colors.cyan.withOpacity(0.5),
                                                blurRadius: 10,
                                                spreadRadius: 2,
                                              ),
                                            ] : [],
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        _buildAnimatedBadge(
                                          'PRESS ENTER',
                                          Colors.purple.withOpacity(0.2),
                                          200,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                // Floating settings button with morphing animation
                Positioned(
                  top: 40,
                  right: 40,
                  child: AnimatedBuilder(
                    animation: _morphAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _morphAnimation.value * math.pi * 2,
                        child: AnimatedOpacity(
                          opacity: _searchFocusNode.hasFocus ? 0.0 : 0.3,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: _generateImages ? [
                                BoxShadow(
                                  color: Colors.cyan.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ] : [],
                            ),
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
                      );
                    },
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
      ),
    );
  }
}

// Minimal error overlay with animations
class _MinimalErrorOverlay extends StatefulWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  const _MinimalErrorOverlay({
    required this.errorMessage,
    required this.onRetry,
    required this.onDismiss,
  });

  @override
  State<_MinimalErrorOverlay> createState() => _MinimalErrorOverlayState();
}

class _MinimalErrorOverlayState extends State<_MinimalErrorOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const SpringCurve(damping: 10, stiffness: 100),
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
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
                        widget.errorMessage.length > 100 
                          ? '${widget.errorMessage.substring(0, 100)}...'
                          : widget.errorMessage,
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
                            onPressed: widget.onDismiss,
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
                            onPressed: widget.onRetry,
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
              );
            },
          ),
        ),
      ),
    );
  }
}

// Navigation helper
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