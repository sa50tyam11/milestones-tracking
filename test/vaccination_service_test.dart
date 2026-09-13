import 'package:flutter_test/flutter_test.dart';
import 'package:child_health_screening/services/vaccination_schedule_service.dart';
import 'package:child_health_screening/core/constants/enums.dart';

void main() {
  group('VaccinationScheduleService Tests', () {
    late VaccinationScheduleService service;

    setUp(() {
      service = VaccinationScheduleService();
    });

    test('isScheduleAvailable is always false initially', () {
      expect(service.isScheduleAvailable(), isFalse);
    });

    test('getDueVaccines throws exception', () {
      expect(() => service.getDueVaccines(DateTime.now()), throwsUnimplementedError);
    });

    test('getModuleResult returns pending state', () {
      final result = service.getModuleResult('child1');

      expect(result.module, 'vaccination');
      expect(result.childId, 'child1');
      expect(result.status, ModuleStatus.pending);
      expect(result.payload?['scheduleAvailable'], isFalse);
    });
  });
}
