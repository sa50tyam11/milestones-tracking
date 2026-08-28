import '../core/constants/enums.dart';
import '../models/child.dart';
import '../models/milestone.dart';
import '../services/milestone_service.dart';

/// The single entry point for all milestone data queries in the module.
///
/// ## Responsibility boundary
/// - [MilestoneService] owns loading, parsing, and caching raw data.
/// - [MilestoneRepository] owns business query logic — translating
///   child-level concepts (a [Child] object) into data-level queries
///   (an [AgeGroup] filter) and returning structured results.
///
/// ## Why a repository on top of a service?
/// The UI and scoring engine should never compute an [AgeGroup] from a
/// [Child] themselves — that logic would be duplicated across every caller.
/// The repository centralises it. When the age classification rules change,
/// only this file changes.
///
/// ## Module boundary
/// This repository is owned exclusively by the Milestone module.
/// The Eye Tracking and Vitamin D modules do not import this class.
/// Integration happens at the backend payload layer via [AssessmentSession].
///
/// ## Usage
/// ```dart
/// final repository = MilestoneRepository(service: milestoneService);
///
/// // Query by child — age group is resolved automatically.
/// final result = repository.getMilestonesForChild(child);
///
/// // Query a specific domain for a child.
/// final motorResult = repository.getDomainMilestonesForChild(
///   child: child,
///   domain: DevelopmentDomain.grossMotor,
/// );
/// ```
class MilestoneRepository {
  const MilestoneRepository({required MilestoneService service})
      : _service = service;

  final MilestoneService _service;

  // ---------------------------------------------------------------------------
  // Child-level queries — primary API used by screens and scoring engine
  // ---------------------------------------------------------------------------

  /// Returns all milestones appropriate for the given [child] based on
  /// their current age, grouped by [DevelopmentDomain].
  ///
  /// Returns a [MilestoneQueryResult] which carries both the milestones
  /// and the resolved [AgeGroup] — the scoring engine and UI both need
  /// the age group, so it is returned alongside the data rather than
  /// forcing callers to recompute it.
  ///
  /// Returns [MilestoneQueryResult.unsupported] if the child's age falls
  /// outside the 2–60 month supported range.
  MilestoneQueryResult getMilestonesForChild(Child child) {
    final ageGroup = child.ageGroup;

    if (ageGroup == null) {
      return MilestoneQueryResult.unsupported(
        childId: child.id,
        ageInMonths: child.ageInMonths,
      );
    }

    final milestones = _service.getMilestonesForAgeGroup(ageGroup);

    return MilestoneQueryResult.success(
      childId: child.id,
      ageGroup: ageGroup,
      milestones: milestones,
    );
  }

  /// Returns milestones for a specific [domain] for the given [child].
  ///
  /// Returns an empty list wrapped in [MilestoneDomainResult] if the
  /// child's age is outside the supported range or no milestones exist
  /// for the domain.
  MilestoneDomainResult getDomainMilestonesForChild({
    required Child child,
    required DevelopmentDomain domain,
  }) {
    final ageGroup = child.ageGroup;

    if (ageGroup == null) {
      return MilestoneDomainResult(
        domain: domain,
        milestones: const [],
        isSupported: false,
      );
    }

    final milestones = _service.getMilestonesForDomain(
      ageGroup: ageGroup,
      domain: domain,
    );

    return MilestoneDomainResult(
      domain: domain,
      milestones: milestones,
      isSupported: true,
    );
  }

  /// Returns only the critical milestones for the given [child].
  ///
  /// Used by the scoring engine to evaluate high-risk flags independently
  /// of domain scores. A 'No' answer on any of these triggers a
  /// doctor-referral recommendation regardless of overall score.
  ///
  /// Returns an empty list if the child's age is outside the supported range.
  List<Milestone> getCriticalMilestonesForChild(Child child) {
    final ageGroup = child.ageGroup;
    if (ageGroup == null) return const [];
    return _service.getCriticalMilestones(ageGroup);
  }

  // ---------------------------------------------------------------------------
  // Age group-level queries — used during session replay and result screen
  // ---------------------------------------------------------------------------

  /// Returns all milestones for a known [ageGroup].
  ///
  /// Used when replaying a historical [AssessmentSession] where the age
  /// group was snapshotted at session time — the child's current age may
  /// have changed since the session was recorded.
  List<Milestone> getMilestonesForAgeGroup(AgeGroup ageGroup) {
    return _service.getMilestonesForAgeGroup(ageGroup);
  }

  /// Returns a single milestone by its stable [id].
  ///
  /// Used by the result screen to resolve milestone titles and descriptions
  /// from the IDs stored in [AssessmentResult].
  ///
  /// Returns null if no milestone with that ID exists.
  Milestone? getMilestoneById(String id) {
    return _service.getMilestoneById(id);
  }

  /// Returns the count of milestones for a given [ageGroup].
  ///
  /// Used by the assessment screen to display progress — "3 of 12 answered".
  int getMilestoneCount(AgeGroup ageGroup) {
    return _service.getMilestoneCount(ageGroup);
  }

  // ---------------------------------------------------------------------------
  // Domain summary — used by result screen
  // ---------------------------------------------------------------------------

  /// Returns a summary of all domains with their milestone counts for a
  /// given [ageGroup].
  ///
  /// Used by the result screen to render the per-domain score breakdown
  /// without fetching the full milestone list for each domain separately.
  List<DomainSummary> getDomainSummaries(AgeGroup ageGroup) {
    return DevelopmentDomain.values.map((domain) {
      final milestones = _service.getMilestonesForDomain(
        ageGroup: ageGroup,
        domain: domain,
      );
      return DomainSummary(
        domain: domain,
        totalMilestones: milestones.length,
        criticalCount: milestones.where((m) => m.isCritical).length,
      );
    }).toList(growable: false);
  }
}

// ---------------------------------------------------------------------------
// Result types — repository methods return structured results, not bare lists
// ---------------------------------------------------------------------------

/// The result of querying milestones for a child.
///
/// Carries the resolved [AgeGroup] alongside the milestones so callers
/// do not need to recompute it. Also handles the unsupported-age case
/// explicitly rather than returning null or throwing.
class MilestoneQueryResult {
  const MilestoneQueryResult._({
    required this.childId,
    required this.isSupported,
    this.ageGroup,
    this.ageInMonths,
    this.milestones = const [],
  });

  /// Successful result — child is within the supported age range.
  factory MilestoneQueryResult.success({
    required String childId,
    required AgeGroup ageGroup,
    required List<Milestone> milestones,
  }) =>
      MilestoneQueryResult._(
        childId: childId,
        isSupported: true,
        ageGroup: ageGroup,
        milestones: milestones,
      );

  /// Unsupported result — child's age is outside the 2–60 month range.
  factory MilestoneQueryResult.unsupported({
    required String childId,
    required int ageInMonths,
  }) =>
      MilestoneQueryResult._(
        childId: childId,
        isSupported: false,
        ageInMonths: ageInMonths,
      );

  final String childId;

  /// Whether the child's age falls within the supported 2–60 month range.
  final bool isSupported;

  /// Resolved age group — null when [isSupported] is false.
  final AgeGroup? ageGroup;

  /// Child's age in months — populated when [isSupported] is false
  /// so the UI can display a meaningful message.
  final int? ageInMonths;

  /// All milestones for the resolved age group, sorted by domain and order.
  /// Empty when [isSupported] is false.
  final List<Milestone> milestones;

  /// Milestones grouped by domain — convenience accessor for the
  /// assessment screen which renders milestones in domain sections.
  Map<DevelopmentDomain, List<Milestone>> get groupedByDomain {
    final map = <DevelopmentDomain, List<Milestone>>{};
    for (final milestone in milestones) {
      map.putIfAbsent(milestone.domain, () => []).add(milestone);
    }
    return Map.unmodifiable(map);
  }

  /// Total number of milestones in this result.
  int get totalCount => milestones.length;

  /// Number of critical milestones in this result.
  int get criticalCount => milestones.where((m) => m.isCritical).length;

  @override
  String toString() => isSupported
      ? 'MilestoneQueryResult(ageGroup: ${ageGroup?.label}, '
        'total: $totalCount, critical: $criticalCount)'
      : 'MilestoneQueryResult.unsupported(ageInMonths: $ageInMonths)';
}

/// The result of querying milestones for a single domain.
class MilestoneDomainResult {
  const MilestoneDomainResult({
    required this.domain,
    required this.milestones,
    required this.isSupported,
  });

  final DevelopmentDomain domain;
  final List<Milestone> milestones;

  /// False when the child's age is outside the supported range.
  final bool isSupported;

  int get totalCount => milestones.length;
  int get criticalCount => milestones.where((m) => m.isCritical).length;

  @override
  String toString() =>
      'MilestoneDomainResult(domain: ${domain.label}, total: $totalCount)';
}

/// A lightweight summary of a single domain's milestone counts.
///
/// Used by the result screen to render domain score cards without
/// needing the full [Milestone] objects.
class DomainSummary {
  const DomainSummary({
    required this.domain,
    required this.totalMilestones,
    required this.criticalCount,
  });

  final DevelopmentDomain domain;
  final int totalMilestones;
  final int criticalCount;

  @override
  String toString() =>
      'DomainSummary(domain: ${domain.label}, total: $totalMilestones, '
      'critical: $criticalCount)';
}