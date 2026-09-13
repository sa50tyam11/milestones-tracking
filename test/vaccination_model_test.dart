import 'package:flutter_test/flutter_test.dart';
import 'package:child_health_screening/models/vaccine.dart';
import 'package:child_health_screening/models/vaccination_record.dart';
import 'package:child_health_screening/core/constants/enums.dart';

void main() {
  group('Vaccine Model Tests', () {
    test('Serialization and Deserialization', () {
      final original = Vaccine(
        id: 'v1',
        name: 'BCG',
        dose: '1',
        scheduledAgeInDays: 0,
        source: 'MoHFW',
        sourceVersion: '2025',
        notes: 'At birth',
      );

      final json = original.toJson();
      final parsed = Vaccine.fromJson(json);

      expect(parsed.id, original.id);
      expect(parsed.name, original.name);
      expect(parsed.dose, original.dose);
      expect(parsed.scheduledAgeInDays, original.scheduledAgeInDays);
      expect(parsed.source, original.source);
      expect(parsed.sourceVersion, original.sourceVersion);
      expect(parsed.notes, original.notes);
    });
  });

  group('VaccinationRecord Model Tests', () {
    test('isValidTechnical returns true for past dates', () {
      final record = VaccinationRecord(
        childId: 'c1',
        vaccineId: 'v1',
        status: VaccineRecordStatus.completed,
        administeredDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(record.isValidTechnical, isTrue);
    });

    test('isValidTechnical returns false for future dates', () {
      final record = VaccinationRecord(
        childId: 'c1',
        vaccineId: 'v1',
        status: VaccineRecordStatus.completed,
        administeredDate: DateTime.now().add(const Duration(days: 1)),
      );

      expect(record.isValidTechnical, isFalse);
    });

    test('Serialization and Deserialization', () {
      final now = DateTime.now();
      final original = VaccinationRecord(
        childId: 'c1',
        vaccineId: 'v1',
        status: VaccineRecordStatus.completed,
        administeredDate: now,
      );

      final json = original.toJson();
      final parsed = VaccinationRecord.fromJson(json);

      expect(parsed.childId, original.childId);
      expect(parsed.vaccineId, original.vaccineId);
      expect(parsed.status, original.status);
      expect(parsed.administeredDate?.toIso8601String(), original.administeredDate?.toIso8601String());
    });
  });
}
