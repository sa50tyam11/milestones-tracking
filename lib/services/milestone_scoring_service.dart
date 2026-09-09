import '../models/assessment_session.dart';
import '../models/assessment_result.dart';
import '../models/milestone.dart';
import '../core/constants/enums.dart';

/// Defines the contract for the clinical scoring engine.
///
/// Converts a raw [AssessmentSession] containing caregiver responses into an
/// interpreted [AssessmentResult].
///
/// ## Phase 8B Status
/// Full clinical numerical scoring rules (thresholds, weights) remain UNDEFINED.
/// This service processes supported rules only:
/// - Determines if `referralRequired` based on `critical` milestones answered "No".
/// - Sets status to `completed_pending_clinical_interpretation`.
class MilestoneScoringService {
  /// Analyzes the [session] against the [assessedMilestones] and generates an [AssessmentResult].
  ///
  /// Throws an [ArgumentError] if the session is invalid or contains no answers.
  AssessmentResult score(AssessmentSession session, List<Milestone> assessedMilestones) {
    if (session.answers.isEmpty) {
      throw ArgumentError('Cannot score an empty assessment session.');
    }

    bool requiresReferral = false;

    // Process explicitly supported rules
    for (final answer in session.answers.values) {
      if (answer.response == AssessmentResponse.no) {
        try {
          final milestone = assessedMilestones.firstWhere((m) => m.id == answer.milestoneId);
          if (milestone.isCritical) {
            requiresReferral = true;
          }
        } catch (e) {
          // Milestone not found in the assessed list, ignore for scoring
        }
      }
    }
    
    // For unsupported numeric scoring, return pending status.
    return AssessmentResult(
      module: 'milestone',
      status: 'completed_pending_clinical_interpretation',
      childId: session.childId,
      sessionId: session.sessionId,
      ageGroup: session.ageGroup,
      referralRequired: requiresReferral,
      scoredAt: DateTime.now(),
    );
  }
}
