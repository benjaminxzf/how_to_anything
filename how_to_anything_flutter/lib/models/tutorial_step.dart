import 'package:json_annotation/json_annotation.dart';

part 'tutorial_step.g.dart';

@JsonSerializable()
class TutorialStep {
  @JsonKey(name: 'step_number')
  final int stepNumber;
  
  final String title;
  final String description;
  final List<String>? tips;
  final List<String>? warnings;
  
  @JsonKey(name: 'tools_needed')
  final List<String>? toolsNeeded;
  
  @JsonKey(name: 'estimated_time')
  final String? estimatedTime;
  
  @JsonKey(name: 'image_prompt')
  final String imagePrompt;
  
  // These will be populated during tutorial generation
  String? imageUrl;
  String? audioUrl;
  
  TutorialStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.imagePrompt,
    this.tips,
    this.warnings,
    this.toolsNeeded,
    this.estimatedTime,
    this.imageUrl,
    this.audioUrl,
  });

  factory TutorialStep.fromJson(Map<String, dynamic> json) =>
      _$TutorialStepFromJson(json);

  Map<String, dynamic> toJson() => _$TutorialStepToJson(this);

  TutorialStep copyWith({
    int? stepNumber,
    String? title,
    String? description,
    String? imagePrompt,
    List<String>? tips,
    List<String>? warnings,
    List<String>? toolsNeeded,
    String? estimatedTime,
    String? imageUrl,
    String? audioUrl,
  }) {
    return TutorialStep(
      stepNumber: stepNumber ?? this.stepNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      imagePrompt: imagePrompt ?? this.imagePrompt,
      tips: tips ?? this.tips,
      warnings: warnings ?? this.warnings,
      toolsNeeded: toolsNeeded ?? this.toolsNeeded,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }
}