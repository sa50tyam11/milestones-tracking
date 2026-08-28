import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/milestone.dart';
import '../core/constants/enums.dart';

/// Loads, parses, and serves [Milestone] objects from the local JSON asset.
///
/// ## Responsibilities
/// - Load `assets/data/milestones.json` from the asset bundle exactly once.
/// - Parse the raw JSON into a typed `List<Milestone>`.
/// - Cache the result in memory for the lifetime of the app session.
/// - Provide filtered queries by [AgeGroup] and [DevelopmentDomain].
///
/// ## What this service does NOT do
/// - It does not know about [AssessmentResult] or [AssessmentSession].
/// - It does not know about scoring, risk levels, or recommendations.
/// - It does not perform network requests.
/// - It does not interact with the Eye Tracking or Vitamin D modules.
///
/// ## Usage
/// ```dart
/// final service = MilestoneService();
/// await service.initialise();
///
/// final milestones = service.getMilestonesForAgeGroup(AgeGroup.twoToThreeMonths);
/// final grossMotor = service.getMilestonesForDomain(
///   ageGroup: AgeGroup.twoToThreeMonths,
///   domain: DevelopmentDomain.grossMotor,
/// );
/// ```
///
/// Call [initialise] once at app startup — before navigating to any screen
/// that needs milestone data. All query methods are synchronous after that.
class MilestoneService {
  MilestoneService({AssetBundle? assetBundle})
      : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;

  // ---------------------------------------------------------------------------
  // Internal cache
  // ---------------------------------------------------------------------------

  /// All milestones parsed from JSON, held for the app session.
  /// Null until [initialise] has been called successfully.
  List<Milestone>? _cache;

  /// Milestones grouped by [AgeGroup] for O(1) group lookup.
  /// Built once during [initialise] alongside [_cache].
  Map<AgeGroup, List<Milestone>>? _groupedCache;

  /// Whether [initialise] has completed successfully.
  bool get isInitialised => _cache != null;

  // ---------------------------------------------------------------------------
  // Initialisation — call once at startup
  // ---------------------------------------------------------------------------

  /// Loads and parses `assets/data/milestones.json`.
  ///
  /// Safe to call multiple times — subsequent calls return immediately
  /// without re-reading or re-parsing the asset.
  ///
  /// Throws a [MilestoneServiceException] if the asset cannot be loaded
  /// or the JSON is malformed.
  Future<void> initialise() async {
    if (isInitialised) return;

    try {
      final jsonString = await _assetBundle.loadString(
        'assets/data/milestones.json',
      );

      final Map<String, dynamic> root =
          json.decode(jsonString) as Map<String, dynamic>;

      final rawList = root['milestones'] as List<dynamic>;

      final milestones = rawList
          .map((e) => Milestone.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);

      _cache = milestones;
      _groupedCache = _buildGroupedCache(milestones);
    } on FormatException catch (e) {
      // FormatException is thrown by json.decode() when milestones.json
      // contains malformed JSON. Must be caught BEFORE the broader
      // Exception block because FormatException is a subtype of Exception.
      throw MilestoneServiceException(
        'milestones.json contains invalid JSON.\n'
        'Detail: ${e.message}',
      );
    } on Exception catch (e) {
      // Catches asset-not-found errors thrown by rootBundle.loadString()
      // when the asset path is missing or not declared in pubspec.yaml.
      // Using Exception rather than FlutterError because the Dart analyzer
      // does not permit FlutterError as an on-catch type in this context,
      // and rootBundle errors surface as Exception subtypes at runtime.
      throw MilestoneServiceException(
        'Failed to load milestones asset. '
        'Ensure assets/data/milestones.json is registered in pubspec.yaml.\n'
        'Detail: $e',
      );
    } catch (e) {
      // Catches Errors (not Exceptions) and any other unexpected throwables.
      // Examples: TypeError from a bad cast in Milestone.fromJson().
      throw MilestoneServiceException(
        'Unexpected error during milestone initialisation.\n'
        'Detail: $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Query API — all synchronous after initialise()
  // ---------------------------------------------------------------------------

  /// Returns all milestones for the given [ageGroup], sorted by domain
  /// and then by [Milestone.order] within each domain.
  ///
  /// Returns an empty list if no milestones exist for the group.
  /// Throws [MilestoneServiceException] if called before [initialise].
  List<Milestone> getMilestonesForAgeGroup(AgeGroup ageGroup) {
    _assertInitialised();
    return List.unmodifiable(
      _groupedCache![ageGroup] ?? const <Milestone>[],
    );
  }

  /// Returns milestones filtered by both [ageGroup] and [domain],
  /// sorted by [Milestone.order].
  ///
  /// Throws [MilestoneServiceException] if called before [initialise].
  List<Milestone> getMilestonesForDomain({
    required AgeGroup ageGroup,
    required DevelopmentDomain domain,
  }) {
    _assertInitialised();
    final groupMilestones = _groupedCache![ageGroup] ?? const <Milestone>[];
    return List.unmodifiable(
      groupMilestones.where((m) => m.domain == domain).toList(growable: false),
    );
  }

  /// Returns only the critical milestones for a given [ageGroup].
  ///
  /// Used by the scoring engine to apply risk-flag logic independently
  /// of the full domain scores.
  ///
  /// Throws [MilestoneServiceException] if called before [initialise].
  List<Milestone> getCriticalMilestones(AgeGroup ageGroup) {
    _assertInitialised();
    final groupMilestones = _groupedCache![ageGroup] ?? const <Milestone>[];
    return List.unmodifiable(
      groupMilestones.where((m) => m.isCritical).toList(growable: false),
    );
  }

  /// Returns a single milestone by its [id].
  ///
  /// Returns null if no milestone with that ID exists.
  /// Throws [MilestoneServiceException] if called before [initialise].
  Milestone? getMilestoneById(String id) {
    _assertInitialised();
    try {
      return _cache!.firstWhere((m) => m.id == id);
    } on StateError {
      return null;
    }
  }

  /// Returns all milestones across every age group that require media upload.
  ///
  /// Useful for pre-flight checks and storage permission prompts.
  /// Throws [MilestoneServiceException] if called before [initialise].
  List<Milestone> getMilestonesRequiringMedia() {
    _assertInitialised();
    return List.unmodifiable(
      _cache!.where((m) => m.requiresMedia).toList(growable: false),
    );
  }

  /// Returns the total number of milestones for a given [ageGroup].
  ///
  /// Throws [MilestoneServiceException] if called before [initialise].
  int getMilestoneCount(AgeGroup ageGroup) {
    _assertInitialised();
    return _groupedCache![ageGroup]?.length ?? 0;
  }

  /// Returns the total number of milestones across all age groups.
  ///
  /// Throws [MilestoneServiceException] if called before [initialise].
  int get totalMilestoneCount {
    _assertInitialised();
    return _cache!.length;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Builds the grouped cache from a flat list.
  /// Runs once during [initialise] — never repeated.
  Map<AgeGroup, List<Milestone>> _buildGroupedCache(
    List<Milestone> milestones,
  ) {
    final map = <AgeGroup, List<Milestone>>{};

    for (final milestone in milestones) {
      map.putIfAbsent(milestone.ageGroup, () => []).add(milestone);
    }

    // Sort each group by domain order then by milestone order within domain.
    for (final group in map.values) {
      group.sort((a, b) {
        final domainCompare = a.domain.index.compareTo(b.domain.index);
        if (domainCompare != 0) return domainCompare;
        return a.order.compareTo(b.order);
      });
    }

    // Freeze each list — callers receive unmodifiable views.
    return map.map((k, v) => MapEntry(k, List.unmodifiable(v)));
  }

  void _assertInitialised() {
    if (!isInitialised) {
      throw MilestoneServiceException(
        'MilestoneService has not been initialised. '
        'Call await milestoneService.initialise() before querying milestones.',
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Exception type
// ---------------------------------------------------------------------------

/// Thrown by [MilestoneService] when initialisation fails or a query
/// is made before [MilestoneService.initialise] has completed.
class MilestoneServiceException implements Exception {
  const MilestoneServiceException(this.message);

  final String message;

  @override
  String toString() => 'MilestoneServiceException: $message';
}