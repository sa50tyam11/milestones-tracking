import 'package:flutter_test/flutter_test.dart';
import 'package:child_health_screening/core/constants/enums.dart';
import 'package:child_health_screening/models/assessment_answer.dart';
import 'package:child_health_screening/models/assessment_session.dart';
import 'package:child_health_screening/services/milestone_scoring_service.dart';

void main() {
  group('MilestoneScoringService - Input Validation', () {
    late MilestoneScoringService scoringService;

    setUp(() {
      scoringService = MilestoneScoringService();
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
        () => scoringService.score(emptySession),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('empty assessment session'),
        )),
      );
    });

    test('Returns AssessmentResult shell for valid input', () {
      final validSession = AssessmentSession(
        sessionId: 'session_123',
        childId: 'child_123',
        ageGroup: AgeGroup.twoToThreeMonths,
        answers: {
          'gm_2m_001': AssessmentAnswer(
            milestoneId: 'gm_2m_001',
            response: AssessmentResponse.yes,
            answeredAt: DateTime.now(),
          ),
        },
        startedAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      final result = scoringService.score(validSession);

      expect(result.sessionId, 'session_123');
      expect(result.childId, 'child_123');
      // scoredAt should be close to now
      expect(
        DateTime.now().difference(result.scoredAt).inSeconds,
        lessThan(2),
      );
    });
  });
}
