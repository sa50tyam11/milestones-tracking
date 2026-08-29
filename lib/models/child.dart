import 'package:flutter/foundation.dart';
import '../core/constants/enums.dart';

/// Represents a registered child in the screening platform.
///
/// ## Design decisions
/// - Fully immutable — all mutations go through [copyWith].
/// - Age and age group are derived at read time from [dateOfBirth] so they
///   never drift out of sync with the stored date.
/// - [parentName] and [phoneNumber] are included for healthcare worker
///   follow-up workflows — they are never used for scoring or assessment logic.
/// - [heightCm] and [weightKg] are nullable — caregivers may not have
///   measurements available at registration time.
///
/// ## Module boundary
/// This model is owned by the Milestone module. It is passed directly to
/// [MilestoneRepository.getMilestonesForChild] which resolves the correct
/// [AgeGroup] from [ageGroup] automatically. The Eye Tracking and Vitamin D
/// modules do not import this class — they receive child identity via
/// [id] at the backend integration layer only.
@immutable
class Child {
  const Child({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.parentName,
    required this.phoneNumber,
    this.vaccinationStatus = VaccinationStatus.unknown,
    this.heightCm,
    this.weightKg,
    this.registeredAt,
  });

  // ---------------------------------------------------------------------------
  // Identity
  // ---------------------------------------------------------------------------

  /// Stable unique identifier for this child record.
  /// Used as the foreign key in [AssessmentSession.childId].
  final String id;

  // ---------------------------------------------------------------------------
  // Personal details
  // ---------------------------------------------------------------------------

  /// Full name of the child.
  final String name;

  /// Date of birth — the single source of truth for all age calculations.
  /// Never store age directly; always derive it from this field.
  final DateTime dateOfBirth;

  /// Biological gender — used for WHO growth chart comparisons.
  final Gender gender;

  /// Full name of the parent or primary caregiver.
  final String parentName;

  /// Contact number of the parent or primary caregiver.
  /// Stored as a string to preserve leading zeros and support
  /// international formats without numeric parsing.
  final String phoneNumber;

  // ---------------------------------------------------------------------------
  // Clinical measurements — nullable, may be filled in post-registration
  // ---------------------------------------------------------------------------

  /// Standing or recumbent height in centimetres.
  /// Null if not yet measured.
  final double? heightCm;

  /// Body weight in kilograms.
  /// Null if not yet measured.
  final double? weightKg;

  // ---------------------------------------------------------------------------
  // Vaccination
  // ---------------------------------------------------------------------------

  /// Current vaccination status as reported by the caregiver.
  final VaccinationStatus vaccinationStatus;

  // ---------------------------------------------------------------------------
  // Audit
  // ---------------------------------------------------------------------------

  /// Timestamp of when this record was first created.
  /// Nullable to support records imported from external sources.
  final DateTime? registeredAt;

  // ---------------------------------------------------------------------------
  // Derived properties
  // ---------------------------------------------------------------------------

  /// Age in complete months calculated from [dateOfBirth] to today.
  ///
  /// Accounts for day-of-month boundary — a child born on the 28th who
  /// is checked on the 27th of the following month has not yet completed
  /// that month.
  ///
  /// Clamped to zero — never returns a negative value for future dates.
  int get ageInMonths {
    final now = DateTime.now();
    int months =
        (now.year - dateOfBirth.year) * 12 + (now.month - dateOfBirth.month);
    if (now.day < dateOfBirth.day) months--;
    return months.clamp(0, 999);
  }

  /// Age in complete years — convenience accessor for display purposes.
  int get ageInYears => ageInMonths ~/ 12;

  /// Resolved WHO age group based on [ageInMonths].
  ///
  /// Returns null when the child's age is outside the supported
  /// 2–60 month range. Callers must handle this case — the registration
  /// screen shows an out-of-range warning, and [MilestoneRepository]
  /// returns [MilestoneQueryResult.unsupported] when this is null.
  AgeGroup? get ageGroup {
    final months = ageInMonths;
    for (final group in AgeGroup.values) {
      final range = group.monthRange;
      if (months >= range.min && months <= range.max) return group;
    }
    return null;
  }

  /// Whether this child's age falls within the supported screening range.
  bool get isWithinScreeningRange => ageGroup != null;

  /// Human-readable age string for display on screens and reports.
  ///
  /// Examples:
  /// - 8 months
  /// - 1 year
  /// - 2 years 4 months
  String get displayAge {
    final months = ageInMonths;
    if (months < 12) return '$months month${months == 1 ? '' : 's'}';
    final years = months ~/ 12;
    final remainder = months % 12;
    final yearStr = '$years year${years == 1 ? '' : 's'}';
    if (remainder == 0) return yearStr;
    return '$yearStr $remainder month${remainder == 1 ? '' : 's'}';
  }

  /// Formatted date of birth for display — DD/MM/YYYY.
  String get displayDateOfBirth {
    final d = dateOfBirth.day.toString().padLeft(2, '0');
    final m = dateOfBirth.month.toString().padLeft(2, '0');
    final y = dateOfBirth.year.toString();
    return '$d/$m/$y';
  }

  /// BMI calculated from [heightCm] and [weightKg].
  /// Returns null if either measurement is missing.
  double? get bmi {
    if (heightCm == null || weightKg == null) return null;
    final heightM = heightCm! / 100;
    return weightKg! / (heightM * heightM);
  }

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id:                json['id'] as String,
      name:              json['name'] as String,
      dateOfBirth:       DateTime.parse(json['dateOfBirth'] as String),
      gender:            Gender.fromJson(json['gender'] as String),
      parentName:        json['parentName'] as String,
      phoneNumber:       json['phoneNumber'] as String,
      vaccinationStatus: VaccinationStatus.fromJson(
                           json['vaccinationStatus'] as String),
      heightCm:          (json['heightCm'] as num?)?.toDouble(),
      weightKg:          (json['weightKg'] as num?)?.toDouble(),
      registeredAt:      json['registeredAt'] != null
                           ? DateTime.parse(json['registeredAt'] as String)
                           : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id':                id,
        'name':              name,
        'dateOfBirth':       dateOfBirth.toIso8601String(),
        'gender':            gender.name,
        'parentName':        parentName,
        'phoneNumber':       phoneNumber,
        'vaccinationStatus': vaccinationStatus.name,
        'heightCm':          heightCm,
        'weightKg':          weightKg,
        'registeredAt':      registeredAt?.toIso8601String(),
      };

  // ---------------------------------------------------------------------------
  // Mutation
  // ---------------------------------------------------------------------------

  /// Returns a new [Child] with the specified fields replaced.
  ///
  /// All unspecified fields carry over from the current instance.
  /// Use this when updating measurements or vaccination status
  /// after the initial registration.
  Child copyWith({
    String? id,
    String? name,
    DateTime? dateOfBirth,
    Gender? gender,
    String? parentName,
    String? phoneNumber,
    VaccinationStatus? vaccinationStatus,
    double? heightCm,
    double? weightKg,
    DateTime? registeredAt,
  }) =>
      Child(
        id:                id                ?? this.id,
        name:              name              ?? this.name,
        dateOfBirth:       dateOfBirth       ?? this.dateOfBirth,
        gender:            gender            ?? this.gender,
        parentName:        parentName        ?? this.parentName,
        phoneNumber:       phoneNumber       ?? this.phoneNumber,
        vaccinationStatus: vaccinationStatus ?? this.vaccinationStatus,
        heightCm:          heightCm          ?? this.heightCm,
        weightKg:          weightKg          ?? this.weightKg,
        registeredAt:      registeredAt      ?? this.registeredAt,
      );

  // ---------------------------------------------------------------------------
  // Equality and identity
  // ---------------------------------------------------------------------------

  /// Two [Child] instances are equal if and only if their [id] matches.
  /// All other fields are content — identity is determined by [id] alone.
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Child && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Child(id: $id, name: $name, age: $displayAge, '
      'gender: ${gender.label}, ageGroup: ${ageGroup?.label ?? 'out of range'})';
}

// ---------------------------------------------------------------------------
// Gender enum — lives here because it is exclusively a Child concern.
// It does not belong in enums.dart which holds module-wide shared enums.
// ---------------------------------------------------------------------------

/// Biological gender of the child.
///
/// Used for WHO growth chart sex-specific comparisons.
/// Stored as a string in JSON via [name] for readability.
enum Gender {
  male,
  female,
  other;

  String get label => switch (this) {
        Gender.male   => 'Male',
        Gender.female => 'Female',
        Gender.other  => 'Other',
      };

  static Gender fromJson(String value) => Gender.values.firstWhere(
        (e) => e.name == value,
        orElse: () => throw ArgumentError(
          'Invalid gender value: "$value". '
          'Expected one of: ${Gender.values.map((e) => e.name).join(', ')}',
        ),
      );
}