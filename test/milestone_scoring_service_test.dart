import 'package:flutter_test/flutter_test.dart';
import 'package:child_health_screening/core/constants/enums.dart';
import 'package:child_health_screening/models/assessment_answer.dart';
import 'package:child_health_screening/models/assessment_session.dart';
import 'package:child_health_screening/models/milestone.dart';
import 'package:child_health_screening/services/milestone_scoring_service.dart';

void main() {
  Milestone createTestMilestone(String id, bool isCritical) {
    return Milestone(
      id: id,
      ageGroup: AgeGroup.twoToThreeMonths,
      domain: DevelopmentDomain.grossMotor,
      title: 'Test $id',
      description: 'Desc',
      instruction: 'Inst',
      question: 'Q?',
      isCritical: isCritical,
      mediaType: MediaType.none,
      requiresAI: false,
      difficulty: MilestoneDifficulty.foundational,
      estimatedTimeSeconds: 30,
      source: 'WHO',
      order: 1,
    );
  }

  group('MilestoneScoringService - Phase 8B', () {
    late MilestoneScoringService scoringService;
    late List<Milestone> mockMilestones;

    setUp(() {
      scoringService = MilestoneScoringService();
      mockMilestones = [
        createTestMilestone('gm_001', false),
        createTestMilestone('gm_002', true),
      ];
    });

    test('Throws ArgumentError when session has no answers', () {
      final emptySession = AssessmentSession(
        sessionId: 'session_123',
        childId: 'child_123',
        ageGroup: AgeGroup.twoToThreeMonths,
        answers: const {},
        startedAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      expect(
        () => scoringService.score(emptySession, mockMilestones),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('empty assessment session'),
        )),
      );
    });

    test('Returns pending status and no referral for non-critical No responses', () {
      final validSession = AssessmentSession(
        sessionId: 'session_123',
        childId: 'child_123',
        ageGroup: AgeGroup.twoToThreeMonths,
        answers: {
          'gm_001': AssessmentAnswer(
            milestoneId: 'gm_001',
            response: AssessmentResponse.no,
            answeredAt: DateTime.now(),
          ),
        },
        startedAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      final result = scoringService.score(validSession, mockMilestones);

      expect(result.sessionId, 'session_123');
      expect(result.childId, 'child_123');
      expect(result.status, 'completed_pending_clinical_interpretation');
      expect(result.referralRequired, false);
      expect(DateTime.now().difference(result.scoredAt).inSeconds, lessThan(2));
    });

    test('Sets referralRequired to true if a critical milestone is answered No', () {
      final validSession = AssessmentSession(
        sessionId: 'session_123',
        childId: 'child_123',
        ageGroup: AgeGroup.twoToThreeMonths,
        answers: {
          'gm_002': AssessmentAnswer(
            milestoneId: 'gm_002',
            response: AssessmentResponse.no, // critical milestone
            answeredAt: DateTime.now(),
          ),
        },
        startedAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      final result = scoringService.score(validSession, mockMilestones);

      expect(result.status, 'completed_pending_clinical_interpretation');
      expect(result.referralRequired, true);
    });

    test('Does not set referralRequired if a critical milestone is answered Yes', () {
      final validSession = AssessmentSession(
        sessionId: 'session_123',
        childId: 'child_123',
        ageGroup: AgeGroup.twoToThreeMonths,
        answers: {
          'gm_002': AssessmentAnswer(
            milestoneId: 'gm_002',
            response: AssessmentResponse.yes, // critical milestone, but passed
            answeredAt: DateTime.now(),
          ),
        },
        startedAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      final result = scoringService.score(validSession, mockMilestones);

      expect(result.referralRequired, false);
    });

    test('Does not set referralRequired if a critical milestone is answered Not Sure', () {
      final validSession = AssessmentSession(
        sessionId: 'session_123',
        childId: 'child_123',
        ageGroup: AgeGroup.twoToThreeMonths,
        answers: {
          'gm_002': AssessmentAnswer(
            milestoneId: 'gm_002',
            response: AssessmentResponse.notSure, // critical milestone, but uncertain
            answeredAt: DateTime.now(),
          ),
        },
        startedAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      final result = scoringService.score(validSession, mockMilestones);

      // We only flag 'no' as requiring referral based on existing specs
      expect(result.referralRequired, false);
    });
  });
}
