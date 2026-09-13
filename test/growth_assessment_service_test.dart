import 'package:flutter_test/flutter_test.dart';
import 'package:child_health_screening/models/growth_assessment.dart';
import 'package:child_health_screening/models/child.dart';
import 'package:child_health_screening/core/constants/enums.dart';
import 'package:child_health_screening/services/growth_assessment_service.dart';

void main() {
  group('GrowthAssessmentService Tests', () {
    late GrowthAssessmentService service;

    setUp(() {
      service = GrowthAssessmentService();
    });

    test('assess should throw if assessment fails technical validation', () {
      final invalidAssessment = GrowthAssessment(
        id: '1',
        childId: 'c1',
        dateOfBirth: DateTime.now(),
        measuredAt: DateTime.now(),
        gender: Gender.male,
        weightKg: -5.0, // Invalid weight
      );

      expect(() => service.assess(invalidAssessment), throwsArgumentError);
    });

    test('assess should return pending ModuleResult when WHO data is missing', () {
      final validAssessment = GrowthAssessment(
        id: '1',
        childId: 'c1',
        dateOfBirth: DateTime.now().subtract(const Duration(days: 30)),
        measuredAt: DateTime.now(),
        gender: Gender.male,
        weightKg: 5.0,
      );

      final result = service.assess(validAssessment);

      expect(result.module, 'growth');
      expect(result.childId, 'c1');
      expect(result.status, ModuleStatus.pending);
      expect(result.payload, isNotNull);
      expect(result.payload!['measurementsCaptured'], true);
      expect(result.payload!['weightKg'], 5.0);
    });
  });
}
