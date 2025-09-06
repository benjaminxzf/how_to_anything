import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class TutorialGenerationOverlay extends StatefulWidget {
  final String progressMessage;

  const TutorialGenerationOverlay({
    Key? key,
    required this.progressMessage,
  }) : super(key: key);

  @override
  State<TutorialGenerationOverlay> createState() => _TutorialGenerationOverlayState();
}

class _TutorialGenerationOverlayState extends State<TutorialGenerationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    _shimmerAnimation = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // Dark gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A0A0F),
                  Color(0xFF1A1A2E),
                  Color(0xFF0A0A0F),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Ghost header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      _buildGhostIcon(),
                      Expanded(
                        child: Center(
                          child: _buildGhostText(width: 120, height: 10),
                        ),
                      ),
                      _buildGhostIcon(),
                    ],
                  ),
                ),
                
                // Ghost cards
                Expanded(
                  child: Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.65,
                      child: PageView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildGhostCard(context, isOverview: true),
                          _buildGhostCard(context),
                          _buildGhostCard(context),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Ghost navigation dots
                Container(
                  padding: const EdgeInsets.only(bottom: 40, top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: index == 0 ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
                
                // Loading message
                Container(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Icon(
                              Icons.auto_awesome,
                              size: 24,
                              color: Colors.cyan.withOpacity(0.6),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'GENERATING TUTORIAL',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 10,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.progressMessage,
                        style: TextStyle(
                          color: Colors.cyan.withOpacity(0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGhostCard(BuildContext context, {bool isOverview = false}) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // Shimmer effect
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            begin: Alignment(_shimmerAnimation.value - 1, 0),
                            end: Alignment(_shimmerAnimation.value, 0),
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.05),
                              Colors.transparent,
                            ],
                            stops: const [0, 0.5, 1],
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: isOverview ? _buildOverviewContent() : _buildStepContent(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildGhostText(width: 200, height: 24),
        const SizedBox(height: 20),
        _buildGhostText(width: 250, height: 14),
        _buildGhostText(width: 230, height: 14),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGhostBadge(),
            const SizedBox(width: 20),
            _buildGhostBadge(),
          ],
        ),
        const SizedBox(height: 30),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: List.generate(3, (_) => _buildGhostChip()),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildGhostCircle(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGhostText(width: 150, height: 14),
                  const SizedBox(height: 4),
                  _buildGhostText(width: 80, height: 10),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          height: 280,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.image_outlined,
              size: 40,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildGhostText(width: double.infinity, height: 14),
        const SizedBox(height: 8),
        _buildGhostText(width: double.infinity, height: 14),
        const SizedBox(height: 8),
        _buildGhostText(width: 200, height: 14),
      ],
    );
  }

  Widget _buildGhostText({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }

  Widget _buildGhostIcon() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildGhostCircle() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.cyan.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.cyan.withOpacity(0.2),
          width: 1,
        ),
      ),
    );
  }

  Widget _buildGhostBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: SizedBox(
        width: 60,
        height: 12,
      ),
    );
  }

  Widget _buildGhostChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: SizedBox(
        width: 50 + (math.Random().nextDouble() * 30),
        height: 10,
      ),
    );
  }
}