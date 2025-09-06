import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/tutorial.dart';

class TutorialOverviewCard extends StatelessWidget {
  final Tutorial tutorial;
  final bool isActive;

  const TutorialOverviewCard({
    Key? key,
    required this.tutorial,
    required this.isActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.cyan.withOpacity(isActive ? 0.3 : 0.1),
                  width: 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    tutorial.title.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 24,
                      fontWeight: FontWeight.w200,
                      letterSpacing: 3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Description
                  Text(
                    tutorial.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Difficulty and Time Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Difficulty Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(tutorial.difficulty).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getDifficultyColor(tutorial.difficulty).withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getDifficultyIcon(tutorial.difficulty),
                              size: 14,
                              color: _getDifficultyColor(tutorial.difficulty),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              tutorial.difficulty.toUpperCase(),
                              style: TextStyle(
                                color: _getDifficultyColor(tutorial.difficulty),
                                fontSize: 11,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 20),
                      
                      // Time Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.cyan.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.cyan.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: Colors.cyan.withOpacity(0.8),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              tutorial.totalTime.toUpperCase(),
                              style: TextStyle(
                                color: Colors.cyan.withOpacity(0.8),
                                fontSize: 11,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Tools Required Section
                  if (tutorial.toolsRequired.isNotEmpty) ...[
                    Text(
                      'TOOLS REQUIRED',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: tutorial.toolsRequired.map((tool) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            tool,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  
                  const SizedBox(height: 40),
                  
                  // Step count indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.cyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.cyan.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.format_list_numbered,
                          size: 16,
                          color: Colors.cyan.withOpacity(0.8),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${tutorial.steps.length} STEPS',
                          style: TextStyle(
                            color: Colors.cyan.withOpacity(0.8),
                            fontSize: 12,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Swipe indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swipe,
                        size: 20,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'SWIPE TO BEGIN',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 10,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.cyan;
    }
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Icons.sentiment_satisfied;
      case 'medium':
        return Icons.sentiment_neutral;
      case 'hard':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.help_outline;
    }
  }
}