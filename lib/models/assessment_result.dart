import 'package:flutter/foundation.dart';
import '../core/constants/enums.dart';

/// The answer a caregiver or healthcare worker recorded for a single milestone.
///
/// One [AssessmentResult] exists per milestone per session.
/// Results are aggregated by the scoring engine — they have no scoring
/// logic themselves (Single Responsibility).
@immutable
class AssessmentResult {
  const AssessmentResult({
    required this.milestoneId,
    required this.answer,
    this.mediaPath,
    this.notes,
    required this.answeredAt,
  });

  /// References [Milestone.id] — the foreign key linking result to milestone.
  final String milestoneId;

  final AssessmentAnswer answer;

  /// Local file path of an uploaded photo or video.
  /// Null when the milestone does not require media, or media was skipped.
  final String? mediaPath;

  /// Optional free-text observation by the assessor.
  final String? notes;

  /// When this answer was recorded — needed for audit trail and offline sync.
  final DateTime answeredAt;

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  factory AssessmentResult.fromJson(Map<String, dynamic> json) =>
      AssessmentResult(
        milestoneId: json['milestoneId'] as String,
        answer:      AssessmentAnswer.fromJson(json['answer'] as String),
        mediaPath:   json['mediaPath'] as String?,
        notes:       json['notes'] as String?,
        answeredAt:  DateTime.parse(json['answeredAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'milestoneId': milestoneId,
        'answer':      answer.name,
        'mediaPath':   mediaPath,
        'notes':       notes,
        'answeredAt':  answeredAt.toIso8601String(),
      };

  AssessmentResult copyWith({
    String? milestoneId,
    AssessmentAnswer? answer,
    String? mediaPath,
    String? notes,
    DateTime? answeredAt,
  }) =>
      AssessmentResult(
        milestoneId: milestoneId ?? this.milestoneId,
        answer:      answer      ?? this.answer,
        mediaPath:   mediaPath   ?? this.mediaPath,
        notes:       notes       ?? this.notes,
        answeredAt:  answeredAt  ?? this.answeredAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssessmentResult && other.milestoneId == milestoneId;

  @override
  int get hashCode => milestoneId.hashCode;

  @override
  String toString() =>
      'AssessmentResult(milestoneId: $milestoneId, answer: ${answer.name})';
}