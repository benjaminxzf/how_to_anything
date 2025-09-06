// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutorial_step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TutorialStep _$TutorialStepFromJson(Map<String, dynamic> json) => TutorialStep(
  stepNumber: (json['step_number'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  imagePrompt: json['image_prompt'] as String,
  tips: (json['tips'] as List<dynamic>?)?.map((e) => e as String).toList(),
  warnings: (json['warnings'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  toolsNeeded: (json['tools_needed'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  estimatedTime: json['estimated_time'] as String?,
  imageUrl: json['imageUrl'] as String?,
  audioUrl: json['audioUrl'] as String?,
);

Map<String, dynamic> _$TutorialStepToJson(TutorialStep instance) =>
    <String, dynamic>{
      'step_number': instance.stepNumber,
      'title': instance.title,
      'description': instance.description,
      'tips': instance.tips,
      'warnings': instance.warnings,
      'tools_needed': instance.toolsNeeded,
      'estimated_time': instance.estimatedTime,
      'image_prompt': instance.imagePrompt,
      'imageUrl': instance.imageUrl,
      'audioUrl': instance.audioUrl,
    };
