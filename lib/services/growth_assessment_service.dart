import '../models/growth_assessment.dart';
import '../models/module_result.dart';
import '../core/constants/enums.dart';

/// Abstract calculator for WHO Child Growth Standards.
/// 
/// DEPENDENCY WARNING:
/// The WHO reference datasets (LMS tables) required for these calculations
/// are currently missing from the repository. 
/// DO NOT fabricate these values. Keep this unimplemented until clinical 
/// data is officially integrated.
abstract class WhoGrowthStandardCalculator {
  /// Calculates z-scores based on WHO Child Growth Standards.
  Map<String, dynamic> calculateZScores(GrowthAssessment assessment);
}

/// A stubbed implementation that explicitly fails if invoked.
class StubWhoGrowthCalculator implements WhoGrowthStandardCalculator {
  @override
  Map<String, dynamic> calculateZScores(GrowthAssessment assessment) {
    throw UnimplementedError(
        'WHO Growth Standard datasets are not yet integrated. '
        'Cannot calculate clinical percentiles or z-scores.');
  }
}

/// Service handling growth assessments and WHO integration boundary.
class GrowthAssessmentService {
  final WhoGrowthStandardCalculator calculator;

  GrowthAssessmentService({WhoGrowthStandardCalculator? calculator})
      : calculator = calculator ?? StubWhoGrowthCalculator();

  /// Processes a growth assessment and returns a ModuleResult suitable for 
  /// dashboard integration.
  /// 
  /// Since WHO calculations are currently unsupported, this returns a 
  /// 'pending' status with raw captured measurements as the payload.
  ModuleResult assess(GrowthAssessment assessment) {
    if (!assessment.isValidTechnical) {
      throw ArgumentError('Growth assessment failed technical validation.');
    }

    Map<String, dynamic> payload = {
      'measurementsCaptured': true,
      if (assessment.weightKg != null) 'weightKg': assessment.weightKg,
      if (assessment.lengthOrHeightCm != null) 'lengthOrHeightCm': assessment.lengthOrHeightCm,
      if (assessment.measurementType != null) 'measurementType': assessment.measurementType!.name,
      if (assessment.headCircumferenceCm != null) 'headCircumferenceCm': assessment.headCircumferenceCm,
    };

    try {
      // Attempt calculation - will throw UnimplementedError with the stub
      final calculations = calculator.calculateZScores(assessment);
      payload.addAll(calculations);
      
      return ModuleResult(
        module: 'growth',
        childId: assessment.childId,
        status: ModuleStatus.completed,
        updatedAt: assessment.measuredAt,
        payload: payload,
      );
    } catch (e) {
      // Fallback: return pending status when WHO data is not available
      return ModuleResult(
        module: 'growth',
        childId: assessment.childId,
        status: ModuleStatus.pending,
        updatedAt: assessment.measuredAt,
        payload: payload,
      );
    }
  }
}
