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
        // Lower temperature for tighter, more concise wording
        temperature: 0.3,
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

  Future<Tutorial> generateTutorial(String howToQuery, {Uint8List? imageBytes}) async {
    final prompt = '''
Create a concise, practical tutorial for: "$howToQuery"

Return ONLY a valid JSON object that matches this schema exactly:
{
  "title": "string",                  // <= 8 words
  "description": "string",            // <= 20 words
  "difficulty": "Easy|Medium|Hard",
  "total_time": "string",
  "tools_required": ["string"],       // essentials only
  "steps": [
    {
      "step_number": 1,
      "title": "string",              // <= 8 words
      "description": "string",        // 1–2 short sentences, <= 35 words total
      "tips": ["string"],             // max 2 items, each <= 10 words
      "warnings": ["string"],         // max 2 items, each <= 10 words
      "tools_needed": ["string"],     // essentials only
      "estimated_time": "string",
      "image_prompt": "string"        // photorealistic instruction; no text in image
    }
  ],
  "safety_notes": ["string"]          // max 2 items, each <= 12 words
}

Style and content rules:
- EXACTLY 2 steps. Combine actions to fit two phases.
- Be brief and specific. Use imperative voice. No fluff or repetition.
- Prefer numbers and units (e.g., 12 in, 2–3 min).
- Keep step descriptions to 1–2 short sentences.
- Tips/Warnings: at most 2 concise bullets each (can be empty arrays).
- Image prompts: photorealistic, consistent setting/lighting, NO TEXT or letters.

Concise example (for "how to tie a tie"):
{
  "title": "Tie a Four-in-Hand Knot",
  "description": "Make a neat classic knot in two steps.",
  "difficulty": "Easy",
  "total_time": "2–3 min",
  "tools_required": ["Necktie", "Mirror"],
  "steps": [
    {
      "step_number": 1,
      "title": "Position and cross",
      "description": "Drape tie, wide end 12 in lower right. Cross wide over narrow at collar.",
      "tips": ["Keep cross close to neck", "Hold the crossing point"],
      "warnings": ["Don't start with short wide end"],
      "tools_needed": ["Necktie"],
      "estimated_time": "30 sec",
      "image_prompt": "Close-up at mirror: hands crossing a navy tie near collar, wide over narrow, white shirt, soft studio lighting, no text"
    },
    {
      "step_number": 2,
      "title": "Form and tighten",
      "description": "Wrap wide end around, up through neck loop, then down through front loop. Slide knot up while holding.",
      "tips": ["Adjust to belt line"],
      "warnings": ["Don't over-tighten"],
      "tools_needed": ["Necktie"],
      "estimated_time": "60 sec",
      "image_prompt": "Hands pulling wide end through front loop, knot forming; white shirt, clear lighting; photoreal; no text"
    }
  ],
  "safety_notes": ["Avoid over-tightening to prevent discomfort"]
}
''';

    try {
      // Prepare content parts for the request
      List<Part> contentParts = [TextPart(prompt)];
      
      // Add image if provided
      if (imageBytes != null) {
        contentParts.add(InlineDataPart('image/jpeg', imageBytes));
      }
      
      final response = await _textModel.generateContent([Content.multi(contentParts)]);
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

  Future<Uint8List> generateStepImage(TutorialStep step, Uint8List? previousImageBytes, {Uint8List? contextImageBytes}) async {
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
      
      // Prepare content parts for image generation
      List<Part> contentParts = [TextPart(imagePrompt)];
      
      // Add context image if provided
      if (contextImageBytes != null) {
        contentParts.add(InlineDataPart('image/jpeg', contextImageBytes));
      }
      
      final response = await _imageModel.generateContent([Content.multi(contentParts)]);
      
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
      Function(int, String?)? onImageUpdate,
      Uint8List? imageBytes}) async {
    
    print('[GeminiService] Starting tutorial generation for: $howToQuery');
    onProgress?.call('Generating tutorial structure...');
    final tutorial = await generateTutorial(howToQuery, imageBytes: imageBytes);
    
    print('[GeminiService] Tutorial text generated with ${tutorial.steps.length} steps');
    // Return tutorial with text immediately
    onProgress?.call('Tutorial text ready! Loading images...');
    
    if (generateImages) {
      print('[GeminiService] Image generation temporarily disabled to save API costs');
      // TODO: Uncomment below lines to re-enable image generation
      /*
      print('[GeminiService] Starting async image generation');
      // Generate images asynchronously after returning the tutorial
      // Important: We don't await this, so the tutorial returns immediately
      _generateImagesAsync(tutorial, onProgress, onImageUpdate, imageBytes).then((_) {
        print('[GeminiService] All images generation completed');
      }).catchError((error) {
        print('[GeminiService] Error in async image generation: $error');
      });
      */
    } else {
      print('[GeminiService] Image generation disabled');
    }
    
    return tutorial;
  }
  
  Future<void> _generateImagesAsync(Tutorial tutorial, 
      Function(String)? onProgress,
      Function(int, String?)? onImageUpdate,
      Uint8List? contextImageBytes) async {
    
    print('[GeminiService] _generateImagesAsync started for ${tutorial.steps.length} steps');
    
    for (int i = 0; i < tutorial.steps.length; i++) {
      final step = tutorial.steps[i];
      print('[GeminiService] Generating image for step ${i + 1}/${tutorial.steps.length}');
      onProgress?.call('Generating image for step ${i + 1} of ${tutorial.steps.length}...');
      
      try {
        // Generate image for this step
        print('[GeminiService] Calling generateStepImage for step ${i + 1}');
        final imageBytes = await generateStepImage(step, null, contextImageBytes: contextImageBytes);
        
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
