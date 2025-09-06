import 'dart:math' as math;
import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/animation_utils.dart';

class LiquidSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSearch;
  final String hintText;
  final double width;
  final Function(Uint8List?)? onImageSelected;
  
  const LiquidSearchBar({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onSearch,
    this.hintText = '',
    this.width = 600,
    this.onImageSelected,
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
  late AnimationController _imageController;
  
  late Animation<double> _morphAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _magnetAnimation;
  late Animation<double> _imageAnimation;
  
  bool _isHovering = false;
  bool _isFocused = false;
  Offset _hoverPosition = Offset.zero;
  double _magneticPull = 0.0;
  
  final List<RippleData> _ripples = [];
  Uint8List? _selectedImageBytes;
  final ImagePicker _imagePicker = ImagePicker();
  
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
    
    _imageController = AnimationController(
      duration: const Duration(milliseconds: 400),
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
    
    _imageAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _imageController,
      curve: Curves.elasticOut,
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
  
  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A25).withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Add Image to Tutorial',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Include an image to help AI create better tutorials',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildImageOptionButton(
                          icon: Icons.photo_library,
                          label: 'Gallery',
                          onTap: () => _pickImage(ImageSource.gallery),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildImageOptionButton(
                          icon: Icons.camera_alt,
                          label: 'Camera',
                          onTap: () => _pickImage(ImageSource.camera),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedImageBytes != null) ...[
                    const SizedBox(height: 16),
                    _buildImageOptionButton(
                      icon: Icons.delete_outline,
                      label: 'Remove Image',
                      onTap: _removeImage,
                      color: Colors.red.withOpacity(0.8),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: (color ?? Colors.cyan).withOpacity(0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color ?? Colors.cyan.withOpacity(0.8),
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: (color ?? Colors.cyan).withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
        });
        _imageController.forward();
        widget.onImageSelected?.call(bytes);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _removeImage() {
    Navigator.pop(context);
    setState(() {
      _selectedImageBytes = null;
    });
    _imageController.reverse();
    widget.onImageSelected?.call(null);
  }

  @override
  void dispose() {
    _morphController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    _magnetController.dispose();
    _imageController.dispose();
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
            _imageAnimation,
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
                          if (_selectedImageBytes != null)
                            AnimatedBuilder(
                              animation: _imageAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _imageAnimation.value,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.cyan.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(7),
                                      child: Image.memory(
                                        _selectedImageBytes!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
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
                              onPressed: _showImagePickerDialog,
                              icon: Icon(
                                Icons.image,
                                color: _selectedImageBytes != null 
                                    ? Colors.cyan.withOpacity(0.8)
                                    : Colors.white.withOpacity(0.4),
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              alignment: Alignment.center,
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