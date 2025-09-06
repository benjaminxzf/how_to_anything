import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_ai/firebase_ai.dart';
import '../models/tutorial.dart';
import '../models/tutorial_step.dart';

class GeminiService {
  late final GenerativeModel _textModel;
  
  static const List<String> _voices = [
    "Puck", "Charon", "Kore", "Fenrir", "Leda", "Zephyr", "Orus", "Aoede"
  ];

  GeminiService() {
    // Initialize text generation model with Firebase AI
    _textModel = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      generationConfig: GenerationConfig(
        temperature: 0.7,
      ),
    );
  }

  Future<Tutorial> generateTutorial(String howToQuery) async {
    final prompt = '''
Create a comprehensive, practical tutorial for: "$howToQuery"

Please respond with a valid JSON object that matches this exact schema:
{
  "title": "string",
  "description": "string", 
  "difficulty": "Easy|Medium|Hard",
  "total_time": "string",
  "tools_required": ["string"],
  "steps": [
    {
      "step_number": 1,
      "title": "string",
      "description": "string",
      "tips": ["string"],
      "warnings": ["string"],
      "tools_needed": ["string"],
      "estimated_time": "string",
      "image_prompt": "string"
    }
  ],
  "safety_notes": ["string"]
}

Guidelines:
- Make the tutorial detailed and actionable
- Include specific measurements, times, and techniques where applicable
- Add helpful tips and safety warnings
- For each step, create a detailed image prompt that describes a photorealistic 
  instructional photo that would help someone complete that step
- Image prompts should maintain consistency in setting, lighting, and style
- Focus on practical, real-world instructions
- Return ONLY the JSON object, no additional text

Example for "how to tie a tie":
{
  "title": "How to Tie a Classic Four-in-Hand Tie",
  "description": "Learn to tie a professional-looking tie knot in 6 simple steps",
  "difficulty": "Easy",
  "total_time": "2-3 minutes",
  "tools_required": ["Necktie", "Mirror"],
  "steps": [
    {
      "step_number": 1,
      "title": "Position the tie around your neck",
      "description": "Drape the tie around your neck with the collar up. The wide end should hang about 12 inches lower than the narrow end on your right side.",
      "tips": ["Make sure the wide end is on your right side", "The exact length may vary based on your height"],
      "warnings": ["Don't make the wide end too short or you won't be able to complete the knot"],
      "tools_needed": ["Necktie"],
      "estimated_time": "10 seconds",
      "image_prompt": "Professional man in white dress shirt standing in front of mirror, draping a navy blue silk tie around his neck, wide end hanging lower on the right side, good lighting"
    }
  ],
  "safety_notes": ["Avoid tying the knot too tightly to prevent discomfort"]
}
''';

    try {
      final response = await _textModel.generateContent([Content.text(prompt)]);
      if (response.text == null || response.text!.isEmpty) {
        throw Exception('No response text received from Gemini');
      }
      
      // Clean the response to extract only JSON
      String jsonText = response.text!.trim();
      
      // Remove any potential markdown formatting
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7);
      }
      if (jsonText.startsWith('```')) {
        jsonText = jsonText.substring(3);
      }
      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3);
      }
      
      final tutorialJson = json.decode(jsonText);
      return Tutorial.fromJson(tutorialJson);
    } catch (e) {
      throw Exception('Error generating tutorial: $e');
    }
  }

  Future<Uint8List> generateStepImage(TutorialStep step, Uint8List? previousImageBytes) async {
    // For now, image generation is disabled - can be enabled when image generation model is properly configured
    throw Exception('Image generation currently disabled - focusing on text tutorials first');
  }

  Future<Uint8List> generateVoiceNarration(String text, int stepNumber) async {
    // Firebase AI doesn't currently support TTS generation
    // This would require Google Cloud Text-to-Speech or similar service
    throw Exception('TTS generation not yet supported with Firebase AI');
  }

  Future<Tutorial> generateCompleteTutorial(String howToQuery, 
      Function(String)? onProgress) async {
    
    onProgress?.call('Generating tutorial structure...');
    final tutorial = await generateTutorial(howToQuery);
    
    // For now, we'll just return the tutorial without images and audio
    // since those features require more complex setup
    onProgress?.call('Tutorial generation complete!');
    
    // Return tutorial with steps but no media
    final updatedSteps = <TutorialStep>[];
    for (final step in tutorial.steps) {
      updatedSteps.add(step.copyWith(
        imageUrl: null, // No image for now
        audioUrl: null, // No audio for now
      ));
    }
    
    return tutorial.copyWith(steps: updatedSteps);
  }
}