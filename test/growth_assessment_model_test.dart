import 'package:flutter_test/flutter_test.dart';
import 'package:child_health_screening/models/growth_assessment.dart';
import 'package:child_health_screening/models/child.dart';
import 'package:child_health_screening/core/constants/enums.dart';

void main() {
  group('GrowthAssessment Model Tests', () {
    test('isValidTechnical should be true for valid measurements', () {
      final assessment = GrowthAssessment(
        id: '1',
        childId: 'c1',
        dateOfBirth: DateTime.now().subtract(const Duration(days: 30)),
        measuredAt: DateTime.now(),
        gender: Gender.male,
        weightKg: 5.0,
        lengthOrHeightCm: 60.0,
        measurementType: MeasurementType.length,
        headCircumferenceCm: 35.0,
      );
      
      expect(assessment.isValidTechnical, isTrue);
    });

    test('isValidTechnical should be false if weight is out of bounds', () {
      final assessment = GrowthAssessment(
        id: '1',
        childId: 'c1',
        dateOfBirth: DateTime.now(),
        measuredAt: DateTime.now(),
        gender: Gender.female,
        weightKg: 105.0, // Invalid
        lengthOrHeightCm: 60.0,
        measurementType: MeasurementType.length,
      );
      
      expect(assessment.isValidTechnical, isFalse);
    });

    test('isValidTechnical should be false if length is provided without type', () {
      final assessment = GrowthAssessment(
        id: '1',
        childId: 'c1',
        dateOfBirth: DateTime.now(),
        measuredAt: DateTime.now(),
        gender: Gender.female,
        weightKg: 5.0,
        lengthOrHeightCm: 60.0,
        measurementType: null, // Invalid since length is provided
      );
      
      expect(assessment.isValidTechnical, isFalse);
    });

    test('isValidTechnical should be false if no measurements provided', () {
      final assessment = GrowthAssessment(
        id: '1',
        childId: 'c1',
        dateOfBirth: DateTime.now(),
        measuredAt: DateTime.now(),
        gender: Gender.female,
      );
      
      expect(assessment.isValidTechnical, isFalse);
    });

    test('Serialization and Deserialization', () {
      final now = DateTime.now();
      final original = GrowthAssessment(
        id: '1',
        childId: 'c1',
        dateOfBirth: now.subtract(const Duration(days: 30)),
        measuredAt: now,
        gender: Gender.male,
        weightKg: 5.0,
        lengthOrHeightCm: 60.0,
        measurementType: MeasurementType.length,
        headCircumferenceCm: 35.0,
      );
      
      final json = original.toJson();
      final parsed = GrowthAssessment.fromJson(json);
      
      expect(parsed.id, original.id);
      expect(parsed.childId, original.childId);
      expect(parsed.weightKg, original.weightKg);
      expect(parsed.lengthOrHeightCm, original.lengthOrHeightCm);
      expect(parsed.measurementType, original.measurementType);
      expect(parsed.headCircumferenceCm, original.headCircumferenceCm);
    });
  });
}
