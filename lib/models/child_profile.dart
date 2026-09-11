import 'package:flutter/foundation.dart';
import 'child.dart';
import 'module_result.dart';
import '../core/constants/enums.dart';

/// Represents the combined assessment state for one child.
/// 
/// This model aggregates the statuses of all modules for the dashboard.
/// It DOES NOT calculate composite risk scores or medical diagnoses.
@immutable
class ChildProfile {
  const ChildProfile({
    required this.child,
    this.milestoneResult,
    this.eyeTrackingResult,
    this.nutritionResult,
  });

  final Child child;
  
  /// Converted from AssessmentResult
  final ModuleResult? milestoneResult;
  
  /// Future integration
  final ModuleResult? eyeTrackingResult;
  
  /// Future integration
  final ModuleResult? nutritionResult;

  /// True ONLY when all three modules are in a 'completed' state.
  /// This is a technical completion check, NOT a medical evaluation.
  bool get isFullyCompleted {
    return _isCompleted(milestoneResult) &&
           _isCompleted(eyeTrackingResult) &&
           _isCompleted(nutritionResult);
  }

  bool _isCompleted(ModuleResult? result) {
    return result != null && result.status == ModuleStatus.completed;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChildProfile &&
          other.child.id == child.id &&
          other.milestoneResult == milestoneResult &&
          other.eyeTrackingResult == eyeTrackingResult &&
          other.nutritionResult == nutritionResult;

  @override
  int get hashCode =>
      child.id.hashCode ^
      milestoneResult.hashCode ^
      eyeTrackingResult.hashCode ^
      nutritionResult.hashCode;

  @override
  String toString() =>
      'ChildProfile(childId: ${child.id}, isFullyCompleted: $isFullyCompleted)';
}
