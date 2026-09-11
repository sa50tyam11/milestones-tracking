import 'package:flutter/foundation.dart';
import '../core/constants/enums.dart';

/// A generic integration abstraction for module results.
/// 
/// This model represents only information common to all modules (Milestone,
/// Eye Tracking, Nutrition). It purposefully DOES NOT define Eye Tracking or 
/// Nutrition fields here.
@immutable
class ModuleResult {
  const ModuleResult({
    required this.module,
    required this.childId,
    required this.status,
    required this.updatedAt,
    this.payload,
  });

  /// The identifier for the module, e.g., 'milestone', 'eye_tracking', 'nutrition'
  final String module;

  /// References [Child.id]
  final String childId;

  /// The technical state of the module assessment
  final ModuleStatus status;

  /// The last time this result was updated
  final DateTime updatedAt;

  /// Generic payload containing the module-specific result data.
  /// This allows future integration without breaking the dashboard contract.
  final Map<String, dynamic>? payload;

  factory ModuleResult.fromJson(Map<String, dynamic> json) => ModuleResult(
        module: json['module'] as String,
        childId: json['childId'] as String,
        status: ModuleStatus.fromJson(json['status'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        payload: json['payload'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        'module': module,
        'childId': childId,
        'status': status.name,
        'updatedAt': updatedAt.toIso8601String(),
        if (payload != null) 'payload': payload,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModuleResult &&
          other.module == module &&
          other.childId == childId &&
          other.status == status &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      module.hashCode ^ childId.hashCode ^ status.hashCode ^ updatedAt.hashCode;

  @override
  String toString() =>
      'ModuleResult(module: $module, childId: $childId, status: $status)';
}
