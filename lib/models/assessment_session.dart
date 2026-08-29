import 'package:flutter/foundation.dart';
import '../core/constants/enums.dart';
import 'assessment_answer.dart';

/// A complete screening session — all milestone answers for one child visit.
///
/// [AssessmentSession] is the top-level object the backend receives (Phase 10)
/// and the scoring engine consumes (Phase 8).
///
/// Results are stored as [Map<String, AssessmentAnswer>] keyed by milestoneId
/// for O(1) lookup — the scoring engine and UI both query by milestone ID
/// constantly, making a list the wrong structure here.
@immutable
class AssessmentSession {
  const AssessmentSession({
    required this.sessionId,
    required this.childId,
    required this.ageGroup,
    required this.answers,
    required this.startedAt,
    this.completedAt,
  });

  final String sessionId;

  /// References [Child.id].
  final String childId;

  /// Snapshot of the child's age group at assessment time.
  /// Stored explicitly because the child's derived [ageGroup] will change
  /// as they grow — this record must reflect what was true at the session.
  final AgeGroup ageGroup;

  /// All milestone answers for this session, keyed by [Milestone.id].
  final Map<String, AssessmentAnswer> answers;

  final DateTime startedAt;

  /// Null until the assessor explicitly submits. Used to distinguish
  /// in-progress sessions from completed ones during offline recovery.
  final DateTime? completedAt;

  // ---------------------------------------------------------------------------
  // Derived properties
  // ---------------------------------------------------------------------------

  bool get isComplete => completedAt != null;

  int get totalAnswered => answers.length;

  /// Convenience: all results where the answer was 'No'.
  List<AssessmentAnswer> get failedAnswers => answers.values
      .where((r) => r.response == AssessmentResponse.no)
      .toList();

  /// Convenience: all results where the answer was 'Not Sure'.
  List<AssessmentAnswer> get uncertainAnswers => answers.values
      .where((r) => r.response == AssessmentResponse.notSure)
      .toList();

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  factory AssessmentSession.fromJson(Map<String, dynamic> json) =>
      AssessmentSession(
        sessionId: json['sessionId'] as String,
        childId:   json['childId'] as String,
        ageGroup:  AgeGroup.fromJson(json['ageGroup'] as String),
        answers: (json['answers'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(
            k,
            AssessmentAnswer.fromJson(v as Map<String, dynamic>),
          ),
        ),
        startedAt:   DateTime.parse(json['startedAt'] as String),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'sessionId':   sessionId,
        'childId':     childId,
        'ageGroup':    ageGroup.name,
        'answers':     answers.map((k, v) => MapEntry(k, v.toJson())),
        'startedAt':   startedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  AssessmentSession copyWith({
    String? sessionId,
    String? childId,
    AgeGroup? ageGroup,
    Map<String, AssessmentAnswer>? answers,
    DateTime? startedAt,
    DateTime? completedAt,
  }) =>
      AssessmentSession(
        sessionId:   sessionId   ?? this.sessionId,
        childId:     childId     ?? this.childId,
        ageGroup:    ageGroup    ?? this.ageGroup,
        answers:     answers     ?? this.answers,
        startedAt:   startedAt   ?? this.startedAt,
        completedAt: completedAt ?? this.completedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssessmentSession && other.sessionId == sessionId;

  @override
  int get hashCode => sessionId.hashCode;

  @override
  String toString() =>
      'AssessmentSession(sessionId: $sessionId, childId: $childId, '
      'answered: $totalAnswered, complete: $isComplete)';
}