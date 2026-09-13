import 'package:flutter/foundation.dart';
import '../core/constants/enums.dart';

/// Represents the status of a specific vaccine for a child.
@immutable
class VaccinationRecord {
  const VaccinationRecord({
    required this.childId,
    required this.vaccineId,
    required this.status,
    this.administeredDate,
  });

  final String childId;
  final String vaccineId;
  final VaccineRecordStatus status;
  final DateTime? administeredDate;

  bool get isValidTechnical {
    if (administeredDate != null) {
      if (administeredDate!.isAfter(DateTime.now())) {
        return false;
      }
    }
    return true;
  }

  Map<String, dynamic> toJson() => {
        'childId': childId,
        'vaccineId': vaccineId,
        'status': status.name,
        'administeredDate': administeredDate?.toIso8601String(),
      };

  factory VaccinationRecord.fromJson(Map<String, dynamic> json) {
    return VaccinationRecord(
      childId: json['childId'] as String,
      vaccineId: json['vaccineId'] as String,
      status: VaccineRecordStatus.fromJson(json['status'] as String),
      administeredDate: json['administeredDate'] != null
          ? DateTime.parse(json['administeredDate'] as String)
          : null,
    );
  }
}
