import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/tutorial_provider.dart';
import '../widgets/tutorial_generation_overlay.dart';
import 'tutorial_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      // Unfocus the text field
      _searchFocusNode.unfocus();
      
      final tutorialProvider = context.read<TutorialProvider>();
      tutorialProvider.generateTutorial(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<TutorialProvider>(
          builder: (context, tutorialProvider, child) {
            return Stack(
              children: [
                // Main content
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF6366F1), // Indigo
                        Color(0xFF8B5CF6), // Violet
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // App icon/logo
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.school_outlined,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 32),
                              
                              // Title
                              const Text(
                                'How To Anything',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              
                              // Subtitle
                              Text(
                                'AI-powered step-by-step tutorials\nwith images and voice guidance',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 24),
                              
                              // Search bar
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  decoration: InputDecoration(
                                    hintText: 'How to...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 18,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Colors.grey[600],
                                      size: 24,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: _handleSearch,
                                      icon: const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Color(0xFF6366F1),
                                      ),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textInputAction: TextInputAction.search,
                                  onSubmitted: (_) => _handleSearch(),
                                ),
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // Example suggestions
                              Text(
                                'Popular tutorials:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      _buildSuggestionChip('tie a tie'),
                                      _buildSuggestionChip('make coffee'),
                                      _buildSuggestionChip('change a tire'),
                                      _buildSuggestionChip('cook pasta'),
                                      _buildSuggestionChip('fold origami'),
                                      _buildSuggestionChip('plant a garden'),
                                      _buildSuggestionChip('bake bread'),
                                      _buildSuggestionChip('solve a rubik\'s cube'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Tutorial generation overlay
                if (tutorialProvider.state == TutorialState.loading)
                  TutorialGenerationOverlay(
                    progressMessage: tutorialProvider.progressMessage,
                  ),
                  
                // Error handling
                if (tutorialProvider.state == TutorialState.error)
                  _ErrorOverlay(
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

  Widget _buildSuggestionChip(String suggestion) {
    return GestureDetector(
      onTap: () {
        _searchController.text = suggestion;
        _handleSearch();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF6366F1).withOpacity(0.3),
          ),
        ),
        child: Text(
          suggestion,
          style: const TextStyle(
            color: Color(0xFF6366F1),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

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
        // Reset the provider when returning from tutorial screen
        context.read<TutorialProvider>().reset();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _ErrorOverlay extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  const _ErrorOverlay({
    required this.errorMessage,
    required this.onRetry,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
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
              // Error icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Error message
              Text(
                errorMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: onDismiss,
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Try Again'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}