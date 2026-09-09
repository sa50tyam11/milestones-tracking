import 'package:flutter/foundation.dart';
import '../models/milestone.dart';
import '../models/assessment_answer.dart';
import '../models/assessment_session.dart';
import '../models/assessment_result.dart';
import '../core/constants/enums.dart';
import '../repositories/milestone_repository.dart';
import '../services/milestone_scoring_service.dart';
import '../services/local_storage_service.dart';
import 'child_provider.dart';

/// Represents the high-level stages of a milestone assessment flow.
enum AssessmentState {
  /// Waiting for a child to be selected or assessment to begin.
  initial,
  /// Actively querying age-appropriate milestones.
  loading,
  /// Milestones are loaded; user is answering questions.
  inProgress,
  /// All required questions have been answered. Ready for submission.
  completed,
  /// Failed to load milestones (e.g. child age out of bounds or JSON error).
  error,
}

/// Manages the state of the active milestone assessment.
///
/// ## Dependency Graph
/// [Widget] -> [MilestoneProvider] -> [MilestoneRepository] -> [MilestoneService]
/// 
/// We keep [MilestoneProvider] focused strictly on UI state (current question, answers).
/// It calls [MilestoneRepository] to handle the business logic of filtering.
/// [MilestoneRepository] calls [MilestoneService] for data access.
class MilestoneProvider extends ChangeNotifier {
  // Dependencies injected via ProxyProvider
  MilestoneRepository? _repository;
  ChildProvider? _childProvider;
  LocalStorageService? _storageService;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  AssessmentState _state = AssessmentState.initial;
  String? _errorMessage;
  DateTime? _startedAt;

  /// The active set of milestones being assessed.
  List<Milestone> _milestones = [];

  /// Tracks the user's answers, keyed by milestoneId.
  final Map<String, AssessmentAnswer> _answers = {};

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  AssessmentState get state => _state;
  String? get errorMessage => _errorMessage;

  List<Milestone> get currentMilestones => List.unmodifiable(_milestones);

  /// Exposes the recorded answers.
  Map<String, AssessmentAnswer> get answers => Map.unmodifiable(_answers);

  /// Calculates assessment progress.
  /// 
  /// For this MVP, we assume all milestones in the list are required.
  /// Progress = answers recorded / total milestones.
  double get progress {
    if (_milestones.isEmpty) return 0.0;
    return _answers.length / _milestones.length;
  }

  // ---------------------------------------------------------------------------
  // Dependency Injection Update
  // ---------------------------------------------------------------------------

  /// Called by `ChangeNotifierProxyProvider3` whenever dependencies change.
  void updateDependencies({
    required MilestoneRepository repository,
    required ChildProvider childProvider,
    required LocalStorageService storageService,
  }) {
    _repository = repository;
    _childProvider = childProvider;
    _storageService = storageService;
  }

  // ---------------------------------------------------------------------------
  // Core Actions
  // ---------------------------------------------------------------------------

  /// Starts the assessment by fetching milestones for the currently active child.
  void loadMilestonesForCurrentChild() {
    final child = _childProvider?.currentChild;
    if (child == null) {
      _setState(AssessmentState.error, error: 'No child selected.');
      return;
    }

    if (_repository == null) {
      _setState(AssessmentState.error, error: 'Repository not available.');
      return;
    }

    _setState(AssessmentState.loading);

    try {
      final result = _repository!.getMilestonesForChild(child);

      if (!result.isSupported) {
        _setState(
          AssessmentState.error,
          error: 'Child age (${result.ageInMonths} months) is outside the supported 2–60 month range.',
        );
        return;
      }

      if (result.milestones.isEmpty) {
        _setState(AssessmentState.error, error: 'No milestones found for this age group.');
        return;
      }

      _milestones = result.milestones;
      _answers.clear();
      _startedAt = DateTime.now();
      _setState(AssessmentState.inProgress);
    } catch (e) {
      _setState(AssessmentState.error, error: e.toString());
    }
  }

  /// Records an answer for a specific milestone.
  void recordAnswer(String milestoneId, AssessmentResponse response, {String? notes, String? mediaPath}) {
    if (_state != AssessmentState.inProgress && _state != AssessmentState.completed) {
      return;
    }

    _answers[milestoneId] = AssessmentAnswer(
      milestoneId: milestoneId,
      response: response,
      notes: notes,
      mediaPath: mediaPath,
      answeredAt: DateTime.now(),
    );

    // Check completion
    if (_answers.length == _milestones.length) {
      _setState(AssessmentState.completed);
    } else {
      // Re-trigger progress updates
      notifyListeners();
    }
  }

  /// Submits the current assessment, generates a session, scores it, and returns the result.
  /// Does not modify the provider's active state, simply executes the scoring flow.
  Future<AssessmentResult?> submitAssessment() async {
    if (_state != AssessmentState.completed) return null;
    
    final child = _childProvider?.currentChild;
    if (child == null) return null;

    final session = AssessmentSession(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(), // MVP session ID
      childId: child.id,
      ageGroup: child.ageGroup!,
      answers: _answers,
      startedAt: _startedAt ?? DateTime.now(),
      completedAt: DateTime.now(),
    );

    final scoringService = MilestoneScoringService();
    final result = scoringService.score(session, _milestones);
    
    // Save to local storage
    if (_storageService != null) {
      await _storageService!.saveAssessmentSession(session);
      await _storageService!.saveAssessmentResult(result);
    }
    
    return result;
  }

  /// Clears all currently recorded answers and resets to inProgress.
  void clearAnswers() {
    if (_milestones.isNotEmpty) {
      _answers.clear();
      _setState(AssessmentState.inProgress);
    }
  }

  /// Resets the provider completely (used when switching children or cancelling).
  void reset() {
    _milestones = [];
    _answers.clear();
    _setState(AssessmentState.initial);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _setState(AssessmentState newState, {String? error}) {
    _state = newState;
    _errorMessage = error;
    notifyListeners();
  }
}
