import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/tutorial.dart';
import '../models/tutorial_step.dart';

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  static const String _textModel = 'gemini-2.5-flash';
  static const String _imageModel = 'gemini-2.5-flash-image-preview';
  
  static const List<String> _voices = [
    "Puck", "Charon", "Kore", "Fenrir", "Leda", "Zephyr", "Orus", "Aoede"
  ];

  String get _apiKey {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in environment variables');
    }
    return key;
  }

  GeminiService();

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
- Between 2-10 steps depending on complexity. Break down complex tasks appropriately.
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
      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      };
      
      // Add image if provided
      if (imageBytes != null) {
        final imageBase64 = base64Encode(imageBytes);
        requestBody['contents'][0]['parts'].add({
          'inline_data': {
            'mime_type': 'image/jpeg',
            'data': imageBase64
          }
        });
      }
      
      final response = await http.post(
        Uri.parse('$_baseUrl/$_textModel:generateContent'),
        headers: {
          'x-goog-api-key': _apiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
      
      final responseData = json.decode(response.body);
      if (responseData['candidates'] == null || responseData['candidates'].isEmpty) {
        throw Exception('No response text received from Gemini');
      }
      
      final content = responseData['candidates'][0]['content'];
      if (content == null || content['parts'] == null || content['parts'].isEmpty) {
        throw Exception('No response text received from Gemini');
      }
      
      final text = content['parts'][0]['text'];
      if (text == null || text.isEmpty) {
        throw Exception('No response text received from Gemini');
      }
      
      // Clean the response to extract only JSON
      String jsonText = text.trim();
      
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

      print('[GeminiService] Sending image generation request via HTTP');
      
      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'contents': [
          {
            'parts': [
              {'text': imagePrompt}
            ]
          }
        ]
      };
      
      // Add context image if provided
      if (contextImageBytes != null) {
        final imageBase64 = base64Encode(contextImageBytes);
        requestBody['contents'][0]['parts'].add({
          'inline_data': {
            'mime_type': 'image/jpeg',
            'data': imageBase64
          }
        });
      }
      
      final response = await http.post(
        Uri.parse('$_baseUrl/$_imageModel:generateContent'),
        headers: {
          'x-goog-api-key': _apiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
      
      final responseData = json.decode(response.body);
      if (responseData['candidates'] == null || responseData['candidates'].isEmpty) {
        throw Exception('No response received from Gemini');
      }
      
      final content = responseData['candidates'][0]['content'];
      if (content == null || content['parts'] == null || content['parts'].isEmpty) {
        throw Exception('No response content received from Gemini');
      }
      
      // Find the inline_data part containing the image
      final parts = content['parts'] as List;
      for (final part in parts) {
        if (part is Map<String, dynamic> && part.containsKey('inlineData')) {
          final inlineData = part['inlineData'];
          if (inlineData != null && inlineData['data'] != null) {
            final imageData = inlineData['data'] as String;
            final bytes = base64Decode(imageData);
            print('[GeminiService] Image generated successfully: ${bytes.length} bytes');
            return bytes;
          }
        }
      }
      
      print('[GeminiService] ERROR: No inline data parts in response');
      print('[GeminiService] Available parts keys: ${parts.map((p) => (p as Map).keys.toList())}');
      throw Exception('No images were generated for step ${step.stepNumber}');
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
    onProgress?.call('Figuring out how to $howToQuery...');
    final tutorial = await generateTutorial(howToQuery, imageBytes: imageBytes);
    
    print('[GeminiService] Tutorial text generated with ${tutorial.steps.length} steps');
    // Return tutorial with text immediately
    onProgress?.call('Tutorial text ready! Loading images...');
    
    if (generateImages) {
      print('[GeminiService] Starting async image generation');
      // Generate images asynchronously after returning the tutorial
      // Important: We don't await this, so the tutorial returns immediately
      _generateImagesAsync(tutorial, onProgress, onImageUpdate, imageBytes).then((_) {
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
