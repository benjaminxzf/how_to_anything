import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/animation_utils.dart';

class LiquidSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSearch;
  final String hintText;
  final double width;
  
  const LiquidSearchBar({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onSearch,
    this.hintText = '',
    this.width = 600,
  }) : super(key: key);

  @override
  State<LiquidSearchBar> createState() => _LiquidSearchBarState();
}

class _LiquidSearchBarState extends State<LiquidSearchBar>
    with TickerProviderStateMixin {
  late AnimationController _morphController;
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late AnimationController _magnetController;
  
  late Animation<double> _morphAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _magnetAnimation;
  
  bool _isHovering = false;
  bool _isFocused = false;
  Offset _hoverPosition = Offset.zero;
  double _magneticPull = 0.0;
  
  final List<RippleData> _ripples = [];
  
  @override
  void initState() {
    super.initState();
    
    _morphController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _magnetController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _morphAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: const SpringCurve(damping: 8, stiffness: 80),
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
    
    _magnetAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _magnetController,
      curve: const MagneticCurve(attraction: 2.0, range: 0.3),
    ));
    
    widget.focusNode.addListener(_onFocusChange);
  }
  
  void _onFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
      if (_isFocused) {
        _morphController.forward();
        _createRipple(Offset(widget.width / 2, 30));
      } else {
        _morphController.reverse();
      }
    });
  }
  
  void _createRipple(Offset position) {
    final ripple = RippleData(
      position: position,
      startTime: DateTime.now(),
      maxRadius: 100,
    );
    
    setState(() {
      _ripples.add(ripple);
    });
    
    _rippleController.forward(from: 0).then((_) {
      setState(() {
        _ripples.remove(ripple);
      });
    });
  }
  
  @override
  void dispose() {
    _morphController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    _magnetController.dispose();
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = math.min(widget.width, screenWidth * 0.9);
    
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          _isHovering = true;
          _magnetController.forward();
        });
      },
      onExit: (event) {
        setState(() {
          _isHovering = false;
          _magnetController.reverse();
          _magneticPull = 0.0;
        });
      },
      onHover: (event) {
        setState(() {
          _hoverPosition = event.localPosition;
          final center = Offset(containerWidth / 2, 30);
          final distance = (event.localPosition - center).distance;
          _magneticPull = math.max(0, 1 - distance / 100);
        });
      },
      child: GestureDetector(
        onTap: () {
          widget.focusNode.requestFocus();
          _createRipple(_hoverPosition);
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _morphAnimation,
            _pulseAnimation,
            _rippleAnimation,
            _magnetAnimation,
          ]),
          builder: (context, child) {
            return Container(
              width: containerWidth,
              height: 60,
              child: CustomPaint(
                painter: LiquidPainter(
                  morphProgress: _morphAnimation.value,
                  pulseProgress: _pulseAnimation.value,
                  isHovering: _isHovering,
                  isFocused: _isFocused,
                  hoverPosition: _hoverPosition,
                  magneticPull: _magneticPull * _magnetAnimation.value,
                  ripples: _ripples,
                  rippleProgress: _rippleAnimation.value,
                ),
                child: ClipPath(
                  clipper: LiquidClipper(
                    morphProgress: _morphAnimation.value,
                    magneticPull: _magneticPull * _magnetAnimation.value,
                    hoverPosition: _hoverPosition,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 10 + _morphAnimation.value * 5,
                      sigmaY: 10 + _morphAnimation.value * 5,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05 + _morphAnimation.value * 0.05),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1 + _morphAnimation.value * 0.1),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: widget.controller,
                              focusNode: widget.focusNode,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                              ),
                              cursorColor: Colors.cyan,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                fillColor: Colors.transparent,
                                filled: false,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                hintText: widget.hintText,
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) => widget.onSearch(),
                            ),
                          ),
                          SizedBox(
                            width: 48,
                            height: 60,
                            child: IconButton(
                              onPressed: widget.onSearch,
                              icon: Icon(
                                _isFocused ? Icons.search : Icons.arrow_forward,
                                color: Colors.white.withOpacity(0.6),
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              alignment: Alignment.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class LiquidPainter extends CustomPainter {
  final double morphProgress;
  final double pulseProgress;
  final bool isHovering;
  final bool isFocused;
  final Offset hoverPosition;
  final double magneticPull;
  final List<RippleData> ripples;
  final double rippleProgress;

  LiquidPainter({
    required this.morphProgress,
    required this.pulseProgress,
    required this.isHovering,
    required this.isFocused,
    required this.hoverPosition,
    required this.magneticPull,
    required this.ripples,
    required this.rippleProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw ripples
    for (final ripple in ripples) {
      final elapsed = DateTime.now().difference(ripple.startTime).inMilliseconds / 800.0;
      final radius = ripple.maxRadius * elapsed.clamp(0.0, 1.0);
      final opacity = (1 - elapsed).clamp(0.0, 1.0);
      
      final paint = Paint()
        ..color = Colors.cyan.withOpacity(opacity * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 * (1 - elapsed);
      
      canvas.drawCircle(ripple.position, radius, paint);
    }
    
    // Draw glow effect
    if (isFocused || isHovering) {
      final glowPaint = Paint()
        ..color = Colors.cyan.withOpacity(0.2 * morphProgress)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          20 + morphProgress * 10,
        );
      
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(30 + morphProgress * 10),
      );
      
      canvas.drawRRect(rect, glowPaint);
    }
    
    // Draw magnetic distortion
    if (magneticPull > 0) {
      final distortionPaint = Paint()
        ..color = Colors.cyan.withOpacity(magneticPull * 0.1)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        hoverPosition,
        30 * magneticPull,
        distortionPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LiquidClipper extends CustomClipper<Path> {
  final double morphProgress;
  final double magneticPull;
  final Offset hoverPosition;

  LiquidClipper({
    required this.morphProgress,
    required this.magneticPull,
    required this.hoverPosition,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final radius = 30.0 + morphProgress * 10;
    
    // Create base rounded rectangle
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    
    path.addRRect(rect);
    
    // Add magnetic deformation
    if (magneticPull > 0) {
      final deformPath = Path();
      final deformRadius = 20 * magneticPull;
      
      // Create control points for smooth deformation
      final controlPoints = <Offset>[];
      for (int i = 0; i < 8; i++) {
        final angle = (i / 8) * 2 * math.pi;
        final basePoint = hoverPosition + Offset(
          math.cos(angle) * deformRadius,
          math.sin(angle) * deformRadius,
        );
        
        // Apply elastic deformation
        final elasticOffset = Offset(
          math.sin(morphProgress * math.pi) * 5,
          math.cos(morphProgress * math.pi) * 5,
        );
        
        controlPoints.add(basePoint + elasticOffset);
      }
      
      // Create smooth curve through control points
      deformPath.moveTo(controlPoints[0].dx, controlPoints[0].dy);
      for (int i = 0; i < controlPoints.length; i++) {
        final current = controlPoints[i];
        final next = controlPoints[(i + 1) % controlPoints.length];
        final control = Offset(
          (current.dx + next.dx) / 2,
          (current.dy + next.dy) / 2,
        );
        
        deformPath.quadraticBezierTo(
          control.dx,
          control.dy,
          next.dx,
          next.dy,
        );
      }
      
      path.addPath(deformPath, Offset.zero);
    }
    
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class RippleData {
  final Offset position;
  final DateTime startTime;
  final double maxRadius;

  RippleData({
    required this.position,
    required this.startTime,
    required this.maxRadius,
  });
}