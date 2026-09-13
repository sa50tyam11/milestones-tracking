import 'package:flutter/foundation.dart';
import '../models/child_profile.dart';
import '../models/module_result.dart';
import '../core/constants/enums.dart';
import '../services/local_storage_service.dart';
import 'child_provider.dart';

/// Aggregates results from multiple modules to build the ChildProfile for the dashboard.
class DashboardProvider extends ChangeNotifier {
  LocalStorageService? _storageService;
  ChildProvider? _childProvider;

  ChildProfile? _currentProfile;
  ChildProfile? get currentProfile => _currentProfile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void updateDependencies({
    required LocalStorageService storageService,
    required ChildProvider childProvider,
  }) {
    final oldChildId = _childProvider?.currentChild?.id;
    _storageService = storageService;
    _childProvider = childProvider;
    
    // Only reload if the child actually changed to prevent infinite loops
    if (oldChildId != childProvider.currentChild?.id || _currentProfile == null) {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    final activeChild = _childProvider?.currentChild;
    if (activeChild == null || _storageService == null) {
      if (_currentProfile != null) {
        _currentProfile = null;
        notifyListeners();
      }
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Fetch milestone result (legacy mapping)
      final existingMilestoneResults = 
          _storageService!.getAssessmentResultsForChild(activeChild.id);
      
      ModuleResult? milestoneModuleResult;
      
      if (existingMilestoneResults.isNotEmpty) {
        // Use the most recent assessment
        existingMilestoneResults.sort((a, b) => b.scoredAt.compareTo(a.scoredAt));
        final latest = existingMilestoneResults.first;
        
        // Convert to ModuleResult without altering existing storage or logic
        milestoneModuleResult = ModuleResult(
          module: 'milestone',
          childId: activeChild.id,
          status: ModuleStatus.completed,
          updatedAt: latest.scoredAt,
        );
      } else {
        milestoneModuleResult = ModuleResult(
          module: 'milestone',
          childId: activeChild.id,
          status: ModuleStatus.notStarted,
          updatedAt: DateTime.now(),
        );
      }

      // 2. Fetch generic Eye Tracking & Nutrition results
      // These may be null if they haven't been saved yet.
      ModuleResult? eyeTrackingResult = _storageService!.getModuleResult(activeChild.id, 'eye_tracking');
      eyeTrackingResult ??= ModuleResult(
        module: 'eye_tracking',
        childId: activeChild.id,
        status: ModuleStatus.notStarted,
        updatedAt: DateTime.now(),
      );

      ModuleResult? growthResult = _storageService!.getModuleResult(activeChild.id, 'growth');
      growthResult ??= ModuleResult(
        module: 'growth',
        childId: activeChild.id,
        status: ModuleStatus.notStarted,
        updatedAt: DateTime.now(),
      );

      ModuleResult? nutritionResult = _storageService!.getModuleResult(activeChild.id, 'nutrition');
      nutritionResult ??= ModuleResult(
        module: 'nutrition',
        childId: activeChild.id,
        status: ModuleStatus.notStarted,
        updatedAt: DateTime.now(),
      );

      _currentProfile = ChildProfile(
        child: activeChild,
        milestoneResult: milestoneModuleResult,
        growthResult: growthResult,
        eyeTrackingResult: eyeTrackingResult,
        nutritionResult: nutritionResult,
      );

    } catch (e) {
      debugPrint('[DashboardProvider] Error loading profile: $e');
      // On failure, preserve existing state but stop loading
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reloads the dashboard profile forcefully
  Future<void> refresh() async {
    await _loadProfile();
  }
}
