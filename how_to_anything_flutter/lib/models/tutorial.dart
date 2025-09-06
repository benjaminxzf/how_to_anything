import 'package:json_annotation/json_annotation.dart';
import 'tutorial_step.dart';

part 'tutorial.g.dart';

@JsonSerializable()
class Tutorial {
  final String title;
  final String description;
  final String difficulty;
  
  @JsonKey(name: 'total_time')
  final String totalTime;
  
  @JsonKey(name: 'tools_required')
  final List<String> toolsRequired;
  
  final List<TutorialStep> steps;
  
  @JsonKey(name: 'safety_notes')
  final List<String>? safetyNotes;

  Tutorial({
    required this.title,
    required this.description,
    required this.difficulty,
    required this.totalTime,
    required this.toolsRequired,
    required this.steps,
    this.safetyNotes,
  });

  factory Tutorial.fromJson(Map<String, dynamic> json) =>
      _$TutorialFromJson(json);

  Map<String, dynamic> toJson() => _$TutorialToJson(this);

  Tutorial copyWith({
    String? title,
    String? description,
    String? difficulty,
    String? totalTime,
    List<String>? toolsRequired,
    List<TutorialStep>? steps,
    List<String>? safetyNotes,
  }) {
    return Tutorial(
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      totalTime: totalTime ?? this.totalTime,
      toolsRequired: toolsRequired ?? this.toolsRequired,
      steps: steps ?? this.steps,
      safetyNotes: safetyNotes ?? this.safetyNotes,
    );
  }
}