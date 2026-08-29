import 'package:flutter/foundation.dart';
import '../core/constants/enums.dart';

/// The answer a caregiver or healthcare worker recorded for a single milestone.
///
/// One [AssessmentAnswer] exists per milestone per session.
/// Answers are aggregated by the scoring engine — they have no scoring
/// logic themselves (Single Responsibility).
@immutable
class AssessmentAnswer {
  const AssessmentAnswer({
    required this.milestoneId,
    required this.response,
    this.mediaPath,
    this.notes,
    required this.answeredAt,
  });

  /// References [Milestone.id] — the foreign key linking result to milestone.
  final String milestoneId;

  final AssessmentResponse response;

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

  factory AssessmentAnswer.fromJson(Map<String, dynamic> json) =>
      AssessmentAnswer(
        milestoneId: json['milestoneId'] as String,
        response:    AssessmentResponse.fromJson(json['response'] as String),
        mediaPath:   json['mediaPath'] as String?,
        notes:       json['notes'] as String?,
        answeredAt:  DateTime.parse(json['answeredAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'milestoneId': milestoneId,
        'response':    response.name,
        'mediaPath':   mediaPath,
        'notes':       notes,
        'answeredAt':  answeredAt.toIso8601String(),
      };

  AssessmentAnswer copyWith({
    String? milestoneId,
    AssessmentResponse? response,
    String? mediaPath,
    String? notes,
    DateTime? answeredAt,
  }) =>
      AssessmentAnswer(
        milestoneId: milestoneId ?? this.milestoneId,
        response:    response    ?? this.response,
        mediaPath:   mediaPath   ?? this.mediaPath,
        notes:       notes       ?? this.notes,
        answeredAt:  answeredAt  ?? this.answeredAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssessmentAnswer && other.milestoneId == milestoneId;

  @override
  int get hashCode => milestoneId.hashCode;

  @override
  String toString() =>
      'AssessmentAnswer(milestoneId: $milestoneId, response: ${response.name})';
}