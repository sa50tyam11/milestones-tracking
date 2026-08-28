/// Centralised enums for the milestone tracking module.
/// Import this wherever domain types are needed — avoids scattered redefinitions.
library;

/// WHO developmental domains assessed per milestone.
enum DevelopmentDomain {
  grossMotor,
  fineMotor,
  languageCommunication,
  cognitive,
  socialBehavioral;

  /// Human-readable label used in UI and reports.
  String get label => switch (this) {
        DevelopmentDomain.grossMotor         => 'Gross Motor',
        DevelopmentDomain.fineMotor          => 'Fine Motor',
        DevelopmentDomain.languageCommunication => 'Language & Communication',
        DevelopmentDomain.cognitive          => 'Cognitive',
        DevelopmentDomain.socialBehavioral   => 'Social & Behavioral',
      };

  /// Icon asset name — wire up your own assets later.
  String get iconName => switch (this) {
        DevelopmentDomain.grossMotor         => 'gross_motor',
        DevelopmentDomain.fineMotor          => 'fine_motor',
        DevelopmentDomain.languageCommunication => 'language',
        DevelopmentDomain.cognitive          => 'cognitive',
        DevelopmentDomain.socialBehavioral   => 'social',
      };

  static DevelopmentDomain fromJson(String value) => DevelopmentDomain.values
      .firstWhere((e) => e.name == value,
          orElse: () => throw ArgumentError('Unknown domain: $value'));
}

/// WHO-aligned age groupings for the 2-month to 5-year range.
enum AgeGroup {
  twoToThreeMonths,
  fourToSixMonths,
  sevenToNineMonths,
  tenToTwelveMonths,
  thirteenToEighteenMonths,
  nineteenToTwentyFourMonths,
  twoToThreeYears,
  threeToFourYears,
  fourToFiveYears;

  String get label => switch (this) {
        AgeGroup.twoToThreeMonths           => '2–3 Months',
        AgeGroup.fourToSixMonths            => '4–6 Months',
        AgeGroup.sevenToNineMonths          => '7–9 Months',
        AgeGroup.tenToTwelveMonths          => '10–12 Months',
        AgeGroup.thirteenToEighteenMonths   => '13–18 Months',
        AgeGroup.nineteenToTwentyFourMonths => '19–24 Months',
        AgeGroup.twoToThreeYears            => '2–3 Years',
        AgeGroup.threeToFourYears           => '3–4 Years',
        AgeGroup.fourToFiveYears            => '4–5 Years',
      };

  /// Inclusive age range in months for boundary checking.
  ({int min, int max}) get monthRange => switch (this) {
        AgeGroup.twoToThreeMonths           => (min: 2,  max: 3),
        AgeGroup.fourToSixMonths            => (min: 4,  max: 6),
        AgeGroup.sevenToNineMonths          => (min: 7,  max: 9),
        AgeGroup.tenToTwelveMonths          => (min: 10, max: 12),
        AgeGroup.thirteenToEighteenMonths   => (min: 13, max: 18),
        AgeGroup.nineteenToTwentyFourMonths => (min: 19, max: 24),
        AgeGroup.twoToThreeYears            => (min: 25, max: 36),
        AgeGroup.threeToFourYears           => (min: 37, max: 48),
        AgeGroup.fourToFiveYears            => (min: 49, max: 60),
      };

  static AgeGroup fromJson(String value) => AgeGroup.values
      .firstWhere((e) => e.name == value,
          orElse: () => throw ArgumentError('Unknown age group: $value'));
}

/// Caregiver's answer for each milestone question.
enum AssessmentAnswer {
  yes,
  no,
  notSure;

  String get label => switch (this) {
        AssessmentAnswer.yes     => 'Yes',
        AssessmentAnswer.no      => 'No',
        AssessmentAnswer.notSure => 'Not Sure',
      };

  static AssessmentAnswer fromJson(String value) =>
      AssessmentAnswer.values.firstWhere((e) => e.name == value,
          orElse: () => throw ArgumentError('Unknown answer: $value'));
}

/// Media type required for some milestones (observation-based evidence).
enum MediaType {
  none,
  photo,
  video;

  static MediaType fromJson(String value) => MediaType.values
      .firstWhere((e) => e.name == value,
          orElse: () => throw ArgumentError('Unknown media type: $value'));
}

/// Output of the scoring engine — used on the result screen and sent to backend.
enum RiskLevel {
  low,
  moderate,
  high;

  String get label => switch (this) {
        RiskLevel.low      => 'Low Risk',
        RiskLevel.moderate => 'Moderate Risk',
        RiskLevel.high     => 'High Risk',
      };

  String get description => switch (this) {
        RiskLevel.low      => 'Development appears on track.',
        RiskLevel.moderate => 'Some areas may need attention.',
        RiskLevel.high     => 'Recommend professional evaluation.',
      };
}

/// Vaccination status options for child registration.
enum VaccinationStatus {
  upToDate,
  partial,
  notVaccinated,
  unknown;

  String get label => switch (this) {
        VaccinationStatus.upToDate       => 'Up to date',
        VaccinationStatus.partial        => 'Partial',
        VaccinationStatus.notVaccinated  => 'Not vaccinated',
        VaccinationStatus.unknown        => 'Unknown',
      };

  static VaccinationStatus fromJson(String value) =>
      VaccinationStatus.values.firstWhere((e) => e.name == value,
          orElse: () => throw ArgumentError('Unknown vaccination status: $value'));
}

enum MilestoneDifficulty {
  foundational,
  developing,
  advanced;

  String get label => switch (this) {
        MilestoneDifficulty.foundational => 'Foundational',
        MilestoneDifficulty.developing   => 'Developing',
        MilestoneDifficulty.advanced     => 'Advanced',
      };

  /// Scoring weight applied by the engine in Phase 8.
  double get scoringWeight => switch (this) {
        MilestoneDifficulty.foundational => 1.0,
        MilestoneDifficulty.developing   => 0.75,
        MilestoneDifficulty.advanced     => 0.5,
      };

  static MilestoneDifficulty fromJson(String value) =>
      MilestoneDifficulty.values.firstWhere(
        (e) => e.name == value,
        orElse: () => throw ArgumentError('Unknown difficulty: $value'),
      );
}