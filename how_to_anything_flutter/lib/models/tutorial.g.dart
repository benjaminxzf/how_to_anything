// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutorial.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tutorial _$TutorialFromJson(Map<String, dynamic> json) => Tutorial(
  title: json['title'] as String,
  description: json['description'] as String,
  difficulty: json['difficulty'] as String,
  totalTime: json['total_time'] as String,
  toolsRequired: (json['tools_required'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  steps: (json['steps'] as List<dynamic>)
      .map((e) => TutorialStep.fromJson(e as Map<String, dynamic>))
      .toList(),
  safetyNotes: (json['safety_notes'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$TutorialToJson(Tutorial instance) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'difficulty': instance.difficulty,
  'total_time': instance.totalTime,
  'tools_required': instance.toolsRequired,
  'steps': instance.steps,
  'safety_notes': instance.safetyNotes,
};
