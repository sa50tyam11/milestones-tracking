import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:child_health_screening/services/local_storage_service.dart';
import 'package:child_health_screening/models/child.dart';
import 'package:child_health_screening/models/assessment_session.dart';
import 'package:child_health_screening/models/assessment_answer.dart';
import 'package:child_health_screening/models/assessment_result.dart';
import 'package:child_health_screening/models/growth_assessment.dart';
import 'package:child_health_screening/core/constants/enums.dart';

void main() {
  group('LocalStorageService Tests', () {
    late LocalStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = LocalStorageService();
      await storage.init();
    });

    Child createTestChild(String id) {
      return Child(
        id: id,
        name: 'Test Child $id',
        dateOfBirth: DateTime(2023, 1, 1),
        gender: Gender.male,
        parentName: 'Test Parent',
        phoneNumber: '1234567890',
      );
    }

    test('1. Child can be saved and retrieved', () async {
      final child = createTestChild('c1');
      await storage.saveChild(child);

      final retrieved = storage.getChild('c1');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Test Child c1');
      expect(retrieved.id, 'c1');
    });

    test('2. Multiple children can be saved and retrieved', () async {
      final child1 = createTestChild('c1');
      final child2 = createTestChild('c2');

      await storage.saveChild(child1);
      await storage.saveChild(child2);

      final allChildren = storage.getAllChildren();
      expect(allChildren.length, 2);
      expect(allChildren.any((c) => c.id == 'c1'), isTrue);
      expect(allChildren.any((c) => c.id == 'c2'), isTrue);
    });

    test('3. Active child ID can be saved, retrieved, and cleared', () async {
      await storage.saveActiveChildId('c1');
      expect(storage.getActiveChildId(), 'c1');

      await storage.clearActiveChildId();
      expect(storage.getActiveChildId(), isNull);
    });

    test('4. AssessmentSession can be saved and retrieved with answers preserved', () async {
      final session = AssessmentSession(
        sessionId: 's1',
        childId: 'c1',
        ageGroup: AgeGroup.twoToThreeMonths,
        answers: {
          'm1': AssessmentAnswer(
            milestoneId: 'm1',
            response: AssessmentResponse.yes,
            answeredAt: DateTime(2023, 5, 1),
          ),
        },
        startedAt: DateTime(2023, 5, 1),
        completedAt: DateTime(2023, 5, 1),
      );

      await storage.saveAssessmentSession(session);

      final sessions = storage.getAssessmentSessionsForChild('c1');
      expect(sessions.length, 1);
      
      final retrieved = sessions.first;
      expect(retrieved.sessionId, 's1');
      expect(retrieved.childId, 'c1');
      expect(retrieved.answers.length, 1);
      expect(retrieved.answers['m1']!.response, AssessmentResponse.yes);
    });

    test('5. AssessmentResult can be saved and retrieved', () async {
      final result = AssessmentResult(
        module: 'milestone',
        status: 'completed_pending_clinical_interpretation',
        childId: 'c1',
        sessionId: 's1',
        ageGroup: AgeGroup.twoToThreeMonths,
        referralRequired: true,
        scoredAt: DateTime(2023, 5, 1),
      );

      await storage.saveAssessmentResult(result);

      final results = storage.getAssessmentResultsForChild('c1');
      expect(results.length, 1);
      
      final retrieved = results.first;
      expect(retrieved.sessionId, 's1');
      expect(retrieved.childId, 'c1');
      expect(retrieved.referralRequired, true);
    });

    test('6. Multiple sessions can exist for the same child', () async {
      final session1 = AssessmentSession(
        sessionId: 's1',
        childId: 'c1',
        ageGroup: AgeGroup.twoToThreeMonths,
        answers: {},
        startedAt: DateTime(2023, 5, 1),
      );
      final session2 = AssessmentSession(
        sessionId: 's2',
        childId: 'c1',
        ageGroup: AgeGroup.fourToSixMonths,
        answers: {},
        startedAt: DateTime(2023, 7, 1),
      );

      await storage.saveAssessmentSession(session1);
      await storage.saveAssessmentSession(session2);

      final sessions = storage.getAssessmentSessionsForChild('c1');
      expect(sessions.length, 2);
      expect(sessions.any((s) => s.sessionId == 's1'), isTrue);
      expect(sessions.any((s) => s.sessionId == 's2'), isTrue);
    });

    test('7. Different children do not receive each other\'s sessions', () async {
      final session1 = AssessmentSession(
        sessionId: 's1',
        childId: 'c1',
        ageGroup: AgeGroup.twoToThreeMonths,
        answers: {},
        startedAt: DateTime(2023, 5, 1),
      );
      final session2 = AssessmentSession(
        sessionId: 's2',
        childId: 'c2',
        ageGroup: AgeGroup.twoToThreeMonths,
        answers: {},
        startedAt: DateTime(2023, 5, 1),
      );

      await storage.saveAssessmentSession(session1);
      await storage.saveAssessmentSession(session2);

      final sessionsC1 = storage.getAssessmentSessionsForChild('c1');
      final sessionsC2 = storage.getAssessmentSessionsForChild('c2');

      expect(sessionsC1.length, 1);
      expect(sessionsC1.first.sessionId, 's1');
      
      expect(sessionsC2.length, 1);
      expect(sessionsC2.first.sessionId, 's2');
    });

    test('8. Missing records are handled safely (return null or empty list)', () {
      expect(storage.getChild('non_existent'), isNull);
      expect(storage.getAssessmentSessionsForChild('non_existent'), isEmpty);
      expect(storage.getAssessmentResultsForChild('non_existent'), isEmpty);
    });

    test('9. Corrupted storage data is handled safely', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('child_c1', '{ corrupted json ...');
      
      // Should not throw, should return null
      final retrieved = storage.getChild('c1');
      expect(retrieved, isNull);
    });

    test('save and retrieve raw growth assessment', () async {
      final assessment = GrowthAssessment(
        id: 'growth1',
        childId: 'child1',
        dateOfBirth: DateTime(2025, 1, 1),
        measuredAt: DateTime(2025, 6, 1),
        gender: Gender.male,
        weightKg: 7.5,
        lengthOrHeightCm: 65.0,
        measurementType: MeasurementType.length,
      );

      await storage.saveGrowthAssessment(assessment);

      final rawAssessments = storage.getGrowthAssessmentsForChildRaw('child1');
      expect(rawAssessments.length, 1);
      expect(rawAssessments.first['id'], 'growth1');
      expect(rawAssessments.first['weightKg'], 7.5);
    });
  });
}
