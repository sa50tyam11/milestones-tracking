import 'package:flutter/foundation.dart';

/// Represents a vaccine definition from an authoritative schedule.
@immutable
class Vaccine {
  const Vaccine({
    required this.id,
    required this.name,
    this.dose,
    this.scheduledAgeInDays,
    required this.source,
    this.sourceVersion,
    this.notes,
  });

  final String id;
  final String name;
  final String? dose;
  final int? scheduledAgeInDays;
  final String source;
  final String? sourceVersion;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dose': dose,
        'scheduledAgeInDays': scheduledAgeInDays,
        'source': source,
        'sourceVersion': sourceVersion,
        'notes': notes,
      };

  factory Vaccine.fromJson(Map<String, dynamic> json) {
    return Vaccine(
      id: json['id'] as String,
      name: json['name'] as String,
      dose: json['dose'] as String?,
      scheduledAgeInDays: json['scheduledAgeInDays'] as int?,
      source: json['source'] as String,
      sourceVersion: json['sourceVersion'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
