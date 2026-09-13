import 'package:flutter/foundation.dart';
import 'child.dart';
import '../core/constants/enums.dart';

@immutable
class GrowthAssessment {
  const GrowthAssessment({
    required this.id,
    required this.childId,
    required this.dateOfBirth,
    required this.measuredAt,
    required this.gender,
    this.weightKg,
    this.lengthOrHeightCm,
    this.measurementType,
    this.headCircumferenceCm,
  });

  final String id;
  final String childId;
  final DateTime dateOfBirth;
  final DateTime measuredAt;
  final Gender gender;

  final double? weightKg;
  final double? lengthOrHeightCm;
  final MeasurementType? measurementType;
  final double? headCircumferenceCm;

  /// Technical validation for sanity checking bounds.
  /// Not a clinical interpretation.
  bool get isValidTechnical {
    if (weightKg != null && (weightKg! <= 0 || weightKg! >= 100)) return false;
    if (lengthOrHeightCm != null && (lengthOrHeightCm! <= 0 || lengthOrHeightCm! >= 250)) return false;
    if (headCircumferenceCm != null && (headCircumferenceCm! <= 0 || headCircumferenceCm! >= 100)) return false;
    
    // Must have at least one valid measurement
    if (weightKg == null && lengthOrHeightCm == null && headCircumferenceCm == null) return false;
    
    // If lengthOrHeight is provided, measurement type must be provided
    if (lengthOrHeightCm != null && measurementType == null) return false;

    return true;
  }

  factory GrowthAssessment.fromJson(Map<String, dynamic> json) => GrowthAssessment(
        id: json['id'] as String,
        childId: json['childId'] as String,
        dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
        measuredAt: DateTime.parse(json['measuredAt'] as String),
        gender: Gender.fromJson(json['gender'] as String),
        weightKg: (json['weightKg'] as num?)?.toDouble(),
        lengthOrHeightCm: (json['lengthOrHeightCm'] as num?)?.toDouble(),
        measurementType: json['measurementType'] != null 
            ? MeasurementType.fromJson(json['measurementType'] as String) 
            : null,
        headCircumferenceCm: (json['headCircumferenceCm'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'childId': childId,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'measuredAt': measuredAt.toIso8601String(),
        'gender': gender.name,
        'weightKg': weightKg,
        'lengthOrHeightCm': lengthOrHeightCm,
        'measurementType': measurementType?.name,
        'headCircumferenceCm': headCircumferenceCm,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GrowthAssessment && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
