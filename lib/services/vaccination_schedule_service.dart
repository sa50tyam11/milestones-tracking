import '../models/module_result.dart';
import '../core/constants/enums.dart';

/// Service boundary for Vaccination Schedule logic.
/// 
/// CLINICAL DEPENDENCY WARNING:
/// Authoritative vaccination schedule data (UIP/NHM/MoHFW or IAP) is MISSING 
/// from the repository.
/// This service intentionally returns a pending/unavailable state and does NOT 
/// fabricate vaccine schedules, due dates, or clinical statuses.
class VaccinationScheduleService {
  final bool authoritativeScheduleAvailable = false;

  /// Returns whether the authoritative schedule data is available.
  bool isScheduleAvailable() {
    return authoritativeScheduleAvailable;
  }

  /// Attempts to calculate due vaccines for a child based on schedule.
  /// Always throws when schedule is not available.
  List<dynamic> getDueVaccines(DateTime dateOfBirth) {
    if (!authoritativeScheduleAvailable) {
      throw UnimplementedError('Authoritative Vaccination Schedule Data Missing.');
    }
    // Return empty list if somehow called and available
    return [];
  }

  /// Generates a structured ModuleResult for the dashboard integration.
  /// Safely returns a 'pending' state with scheduleAvailable: false 
  /// without fabricating completed/due counts.
  ModuleResult getModuleResult(String childId) {
    if (!authoritativeScheduleAvailable) {
      return ModuleResult(
        module: 'vaccination',
        childId: childId,
        status: ModuleStatus.pending,
        updatedAt: DateTime.now(),
        payload: {
          'scheduleAvailable': false,
        },
      );
    }
    
    // Future integration when schedule data exists
    return ModuleResult(
      module: 'vaccination',
      childId: childId,
      status: ModuleStatus.notStarted,
      updatedAt: DateTime.now(),
      payload: {
        'scheduleAvailable': true,
      },
    );
  }
}
