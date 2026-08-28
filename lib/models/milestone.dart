import 'package:flutter/foundation.dart';
import '../core/constants/enums.dart';

/// A single WHO-sourced developmental checkpoint.
///
/// Milestones are immutable data objects loaded once from
/// `assets/data/milestones.json` by [MilestoneService].
/// They are never mutated at runtime.
///
/// Assessment answers are stored separately in [AssessmentResult] —
/// this model holds only the definition of the milestone, not the response.
///
/// ## Module boundary
/// This model is owned by the Milestone module. The Eye Tracking and
/// Vitamin D modules do not import this class. Integration happens at
/// the backend API layer (Phase 10) via [AssessmentSession.toJson].
@immutable
class Milestone {
  const Milestone({
    required this.id,
    required this.ageGroup,
    required this.domain,
    required this.title,
    required this.description,
    required this.instruction,
    required this.question,
    required this.isCritical,
    required this.mediaType,
    required this.requiresAI,
    required this.difficulty,
    required this.estimatedTimeSeconds,
    required this.source,
    required this.order,
  });

  // ---------------------------------------------------------------------------
  // Identity
  // ---------------------------------------------------------------------------

  /// Stable unique identifier. Format: `{domain}_{agePrefix}_{sequence}`
  /// Example: `gm_2m_001` — Gross Motor, 2-month group, first milestone.
  /// This ID is the foreign key used in [AssessmentResult.milestoneId].
  final String id;

  // ---------------------------------------------------------------------------
  // Classification
  // ---------------------------------------------------------------------------

  /// WHO age group this milestone belongs to.
  /// Used by [MilestoneService] to filter milestones for a given child.
  final AgeGroup ageGroup;

  /// Developmental domain this milestone assesses.
  /// Used by the scoring engine to compute per-domain scores.
  final DevelopmentDomain domain;

  // ---------------------------------------------------------------------------
  // Content
  // ---------------------------------------------------------------------------

  /// Short label shown in list views and result screens.
  /// Example: "Lifts head during tummy time"
  final String title;

  /// Clinical context explaining the developmental significance of this
  /// milestone. Shown to healthcare workers — not to parents directly.
  /// Example: "Head lifting indicates developing neck extensor strength..."
  final String description;

  /// Step-by-step instructions for the assessor to elicit the behaviour.
  /// Shown on the assessment screen before the question.
  /// Example: "Place the baby face-down on a firm, flat surface..."
  final String instruction;

  /// The exact Yes / No / Not Sure question shown in the assessment UI.
  /// Always phrased as a closed question about observable behaviour.
  /// Example: "Does the baby lift their head while lying on their tummy?"
  final String question;

  // ---------------------------------------------------------------------------
  // Scoring and risk flags
  // ---------------------------------------------------------------------------

  /// When true, a 'No' answer triggers a high-risk flag in the scoring engine
  /// regardless of other domain scores, and generates a doctor-referral
  /// recommendation on the result screen.
  final bool isCritical;

  /// Clinical and developmental weight of this milestone within its age group.
  /// Used by the scoring engine to apply weighted scoring per domain.
  final MilestoneDifficulty difficulty;

  // ---------------------------------------------------------------------------
  // Assessment requirements
  // ---------------------------------------------------------------------------

  /// The type of media the assessor must upload for this milestone.
  /// [MediaType.none] means no media is required.
  final MediaType mediaType;

  /// Whether this milestone requires AI-assisted analysis.
  ///
  /// Currently false for all milestones in this module.
  /// This field is the integration hook for the Eye Tracking module —
  /// if a visual or cognitive milestone is flagged true, the backend
  /// requests an eye tracking result to cross-validate the answer.
  /// This module never reads or acts on this field itself.
  final bool requiresAI;

  /// Estimated time in seconds to complete this milestone assessment.
  /// Used on the assessment screen to display a progress estimate.
  final int estimatedTimeSeconds;

  // ---------------------------------------------------------------------------
  // Metadata
  // ---------------------------------------------------------------------------

  /// Publication or document this milestone is sourced from.
  /// Example: "WHO Motor Development Study" or "WHO Developmental Milestones"
  final String source;

  /// Display order within a domain group for a given age group.
  /// Lower values appear first.
  final int order;

  // ---------------------------------------------------------------------------
  // Derived properties
  // ---------------------------------------------------------------------------

  /// True when this milestone requires the assessor to upload media.
  bool get requiresMedia => mediaType != MediaType.none;

  /// Estimated time formatted for display.
  /// Returns "30 sec", "2 min", "1 min 30 sec" etc.
  String get estimatedTimeDisplay {
    if (estimatedTimeSeconds < 60) {
      return '${estimatedTimeSeconds}s';
    }
    final minutes = estimatedTimeSeconds ~/ 60;
    final seconds = estimatedTimeSeconds % 60;
    if (seconds == 0) return '${minutes}m';
    return '${minutes}m ${seconds}s';
  }

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id:                   json['id'] as String,
      ageGroup:             AgeGroup.fromJson(json['ageGroup'] as String),
      domain:               DevelopmentDomain.fromJson(json['domain'] as String),
      title:                json['title'] as String,
      description:          json['description'] as String,
      instruction:          json['instruction'] as String,
      question:             json['question'] as String,
      isCritical:           json['critical'] as bool,
      mediaType:            MediaType.fromJson(json['mediaType'] as String),
      requiresAI:           json['requiresAI'] as bool,
      difficulty:           MilestoneDifficulty.fromJson(
                              json['difficulty'] as String),
      estimatedTimeSeconds: json['estimatedTimeSeconds'] as int,
      source:               json['source'] as String,
      order:                json['order'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id':                   id,
        'ageGroup':             ageGroup.name,
        'domain':               domain.name,
        'title':                title,
        'description':          description,
        'instruction':          instruction,
        'question':             question,
        'critical':             isCritical,
        'mediaType':            mediaType.name,
        'requiresAI':           requiresAI,
        'difficulty':           difficulty.name,
        'estimatedTimeSeconds': estimatedTimeSeconds,
        'source':               source,
        'order':                order,
      };

  // ---------------------------------------------------------------------------
  // Equality and identity
  // ---------------------------------------------------------------------------

  /// Two milestones are equal if and only if their IDs match.
  /// ID is the stable identity — all other fields are content.
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Milestone && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Milestone(id: $id, domain: ${domain.label}, title: $title)';
}