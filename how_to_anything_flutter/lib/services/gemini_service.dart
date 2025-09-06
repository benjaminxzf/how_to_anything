import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_ai/firebase_ai.dart';
import '../models/tutorial.dart';
import '../models/tutorial_step.dart';

class GeminiService {
  late final GenerativeModel _textModel;
  late final GenerativeModel _imageModel;
  
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
    
    // Initialize image generation model with Firebase AI
    _imageModel = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash-image-preview',
      generationConfig: GenerationConfig(
        temperature: 0.7,
        responseModalities: [ResponseModalities.text, ResponseModalities.image],
      ),
    );
  }

  Future<Tutorial> generateTutorial(String howToQuery) async {
    final prompt = '''
Create a concise, practical tutorial for: "$howToQuery"

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
- Create tutorials with EXACTLY 2 steps for optimal mobile viewing experience
- Make each step substantial, detailed and actionable - combine multiple actions if needed
- Include specific measurements, times, and techniques where applicable
- Add helpful tips and safety warnings for each step
- For each step, create a detailed image prompt that describes a photorealistic 
  instructional photo that would help someone complete that step
- Image prompts should maintain consistency in setting, lighting, and style
- Focus on the most essential actions - break complex tasks into 2 main phases
- Image prompts should specify NO TEXT or words should appear in the generated image
- Return ONLY the JSON object, no additional text

Example for "how to tie a tie":
{
  "title": "How to Tie a Classic Four-in-Hand Tie",
  "description": "Learn to tie a professional-looking tie knot in 2 simple steps",
  "difficulty": "Easy",
  "total_time": "2-3 minutes",
  "tools_required": ["Necktie", "Mirror"],
  "steps": [
    {
      "step_number": 1,
      "title": "Position and cross the tie",
      "description": "Drape the tie around your neck with collar up, wide end 12 inches lower on your right. Cross the wide end over the narrow end near your collar, creating an X-shape. Hold this crossing point firmly with your non-dominant hand.",
      "tips": ["Keep the wide end on your right side", "The crossing should be close to your neck", "Maintain firm grip on the crossing point"],
      "warnings": ["Don't make the wide end too short or you won't complete the knot"],
      "tools_needed": ["Necktie"],
      "estimated_time": "30 seconds",
      "image_prompt": "Professional man in white dress shirt at mirror, hands positioned crossing a navy silk tie near his collar, wide end over narrow end forming X-shape, focused on hand positioning"
    },
    {
      "step_number": 2,
      "title": "Form and tighten the knot",
      "description": "Wrap the wide end behind and around the narrow end, then pull it up through the neck loop from underneath. Pull the wide end down through the front loop you just created, then slide the knot up by pulling the narrow end while holding the knot.",
      "tips": ["Keep movements smooth and controlled", "Adjust knot position by sliding up or down", "The wide end should reach your belt buckle"],
      "warnings": ["Don't pull too hard or the knot will become too tight"],
      "tools_needed": ["Necktie"],
      "estimated_time": "60 seconds",
      "image_prompt": "Close-up of hands completing a tie knot, pulling wide end through the front loop, navy silk tie against white dress shirt, professional lighting showing knot formation detail"
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
    print('[GeminiService] generateStepImage called for step ${step.stepNumber}: ${step.title}');
    try {
      // Create a detailed prompt for image generation
      final imagePrompt = '''
Generate a clear, instructional photo for step ${step.stepNumber} of a tutorial: "${step.title}"

Image requirements:
- ${step.imagePrompt}
- Professional, well-lit instructional style
- Clear focus on the main action or object
- Photorealistic quality
- Clean, uncluttered composition
- Suitable for educational/tutorial content
- NO TEXT, NO WORDS, NO LETTERS visible in the image
- NO captions, labels, or written instructions
- Focus purely on visual demonstration
- Show hands, tools, objects, and actions without any text overlay

Additional context:
${step.description.length > 200 ? step.description.substring(0, 200) + '...' : step.description}
''';

      print('[GeminiService] Sending image generation request to Firebase AI');
      final prompt = [Content.text(imagePrompt)];
      final response = await _imageModel.generateContent(prompt);
      
      print('[GeminiService] Response received, checking for inline data parts');
      if (response.inlineDataParts.isNotEmpty) {
        final bytes = response.inlineDataParts.first.bytes;
        print('[GeminiService] Image generated successfully: ${bytes.length} bytes');
        return bytes;
      } else {
        print('[GeminiService] ERROR: No inline data parts in response');
        throw Exception('No images were generated for step ${step.stepNumber}');
      }
    } catch (e) {
      throw Exception('Error generating image for step ${step.stepNumber}: $e');
    }
  }

  Future<Uint8List> generateVoiceNarration(String text, int stepNumber) async {
    // Firebase AI doesn't currently support TTS generation
    // This would require Google Cloud Text-to-Speech or similar service
    throw Exception('TTS generation not yet supported with Firebase AI');
  }

  Future<Tutorial> generateCompleteTutorial(String howToQuery, 
      Function(String)? onProgress, 
      {bool generateImages = true,
      Function(int, String?)? onImageUpdate}) async {
    
    print('[GeminiService] Starting tutorial generation for: $howToQuery');
    onProgress?.call('Generating tutorial structure...');
    final tutorial = await generateTutorial(howToQuery);
    
    print('[GeminiService] Tutorial text generated with ${tutorial.steps.length} steps');
    // Return tutorial with text immediately
    onProgress?.call('Tutorial text ready! Loading images...');
    
    if (generateImages) {
      print('[GeminiService] Starting async image generation');
      // Generate images asynchronously after returning the tutorial
      // Important: We don't await this, so the tutorial returns immediately
      _generateImagesAsync(tutorial, onProgress, onImageUpdate).then((_) {
        print('[GeminiService] All images generation completed');
      }).catchError((error) {
        print('[GeminiService] Error in async image generation: $error');
      });
    } else {
      print('[GeminiService] Image generation disabled');
    }
    
    return tutorial;
  }
  
  Future<void> _generateImagesAsync(Tutorial tutorial, 
      Function(String)? onProgress,
      Function(int, String?)? onImageUpdate) async {
    
    print('[GeminiService] _generateImagesAsync started for ${tutorial.steps.length} steps');
    
    for (int i = 0; i < tutorial.steps.length; i++) {
      final step = tutorial.steps[i];
      print('[GeminiService] Generating image for step ${i + 1}/${tutorial.steps.length}');
      onProgress?.call('Generating image for step ${i + 1} of ${tutorial.steps.length}...');
      
      try {
        // Generate image for this step
        print('[GeminiService] Calling generateStepImage for step ${i + 1}');
        final imageBytes = await generateStepImage(step, null);
        
        print('[GeminiService] Image bytes received: ${imageBytes.length} bytes');
        // Convert to base64 data URL
        final base64String = base64Encode(imageBytes);
        final imageDataUrl = 'data:image/png;base64,$base64String';
        
        print('[GeminiService] Image converted to base64, calling onImageUpdate');
        // Notify about the image update
        onImageUpdate?.call(i, imageDataUrl);
        
        onProgress?.call('Generated image for step ${i + 1} of ${tutorial.steps.length}');
        print('[GeminiService] Successfully generated image for step ${i + 1}');
      } catch (e) {
        // If image generation fails, continue without image
        print('[GeminiService] ERROR: Failed to generate image for step ${i + 1}: $e');
        onProgress?.call('Skipped image for step ${i + 1} (generation failed)');
        onImageUpdate?.call(i, null);
      }
    }
    
    onProgress?.call('All images loaded!');
    print('[GeminiService] _generateImagesAsync completed');
  }
}