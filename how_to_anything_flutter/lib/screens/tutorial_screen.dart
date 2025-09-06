import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import '../models/tutorial.dart';
import '../widgets/tutorial_step_card.dart';
import '../widgets/tutorial_header.dart';
import '../widgets/step_indicator.dart';

class TutorialScreen extends StatefulWidget {
  final Tutorial tutorial;

  const TutorialScreen({Key? key, required this.tutorial}) : super(key: key);

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final SwiperController _swiperController = SwiperController();
  int _currentIndex = 0;
  bool _showHeader = true;

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  void _onIndexChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _toggleHeader() {
    setState(() {
      _showHeader = !_showHeader;
    });
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.tutorial.steps;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header section (collapsible)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _showHeader ? null : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showHeader ? 1.0 : 0.0,
                child: TutorialHeader(
                  tutorial: widget.tutorial,
                  onClose: () => Navigator.of(context).pop(),
                  onToggle: _toggleHeader,
                ),
              ),
            ),
            
            // Step indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _showHeader ? _toggleHeader : null,
                    icon: Icon(
                      _showHeader ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey[600],
                    ),
                  ),
                  Expanded(
                    child: StepIndicator(
                      currentStep: _currentIndex + 1,
                      totalSteps: steps.length,
                      onStepTap: (index) {
                        _swiperController.move(index);
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            // Tutorial cards
            Expanded(
              child: Swiper(
                controller: _swiperController,
                itemCount: steps.length,
                onIndexChanged: _onIndexChanged,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TutorialStepCard(
                      step: steps[index],
                      isActive: index == _currentIndex,
                    ),
                  );
                },
                viewportFraction: 0.9,
                scale: 0.85,
                pagination: const SwiperPagination(
                  builder: DotSwiperPaginationBuilder(
                    activeColor: Color(0xFF6366F1),
                    color: Colors.grey,
                    size: 8,
                    activeSize: 12,
                  ),
                ),
                control: SwiperControl(
                  iconPrevious: Icons.arrow_back_ios,
                  iconNext: Icons.arrow_forward_ios,
                  color: const Color(0xFF6366F1),
                  disableColor: Colors.grey,
                  size: 24,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
            
            // Bottom navigation
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Previous button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _currentIndex > 0
                          ? () => _swiperController.previous()
                          : null,
                      icon: const Icon(Icons.arrow_back_ios, size: 16),
                      label: const Text('Previous'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.grey[700],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Next/Complete button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_currentIndex < steps.length - 1) {
                          _swiperController.next();
                        } else {
                          // Tutorial completed
                          _showCompletionDialog();
                        }
                      },
                      icon: Icon(
                        _currentIndex < steps.length - 1
                            ? Icons.arrow_forward_ios
                            : Icons.check_circle,
                        size: 16,
                      ),
                      label: Text(
                        _currentIndex < steps.length - 1 ? 'Next Step' : 'Complete',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration,
                color: Colors.green,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Congratulations!'),
          ],
        ),
        content: Text(
          'You\'ve completed the tutorial: "${widget.tutorial.title}"\n\nWell done! 🎉',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to home
            },
            child: const Text('Create Another Tutorial'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to home
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}