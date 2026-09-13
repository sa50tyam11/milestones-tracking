import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:child_health_screening/core/constants/enums.dart';
import 'package:child_health_screening/models/module_result.dart';
import 'package:child_health_screening/models/child_profile.dart';
import 'package:child_health_screening/models/child.dart';
import 'package:child_health_screening/models/assessment_result.dart';
import 'package:child_health_screening/services/local_storage_service.dart';
import 'package:child_health_screening/providers/child_provider.dart';
import 'package:child_health_screening/providers/dashboard_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ModuleStatus Serialization', () {
    test('1. ModuleStatus serialization works correctly', () {
      expect(ModuleStatus.completed.name, 'completed');
      expect(ModuleStatus.pending.name, 'pending');
      
      expect(ModuleStatus.fromJson('completed'), ModuleStatus.completed);
      expect(ModuleStatus.fromJson('pending'), ModuleStatus.pending);
    });
  });

  group('ModuleResult Tests', () {
    final now = DateTime.now();
    
    test('2. ModuleResult creation', () {
      final result = ModuleResult(
        module: 'milestone',
        childId: 'child_1',
        status: ModuleStatus.completed,
        updatedAt: now,
      );
      
      expect(result.module, 'milestone');
      expect(result.childId, 'child_1');
      expect(result.status, ModuleStatus.completed);
    });

    test('3 & 4. ModuleResult toJson and fromJson', () {
      final result = ModuleResult(
        module: 'nutrition',
        childId: 'child_2',
        status: ModuleStatus.pending,
        updatedAt: now,
        payload: {'score': 10},
      );
      
      final json = result.toJson();
      final parsed = ModuleResult.fromJson(json);
      
      expect(parsed.module, result.module);
      expect(parsed.childId, result.childId);
      expect(parsed.status, result.status);
      expect(parsed.payload?['score'], 10);
    });

    test('5. Malformed ModuleResult JSON handles errors safely', () {
      final malformedJson = {
        'module': 'nutrition',
        'childId': 'child_2',
        'status': 'INVALID_STATUS', // This should throw
        'updatedAt': now.toIso8601String(),
      };
      
      expect(() => ModuleResult.fromJson(malformedJson), throwsArgumentError);
    });
  });

  group('ChildProfile & Aggregation Tests', () {
    final child = Child(
      id: 'child_1',
      name: 'Test Child',
      dateOfBirth: DateTime.now().subtract(const Duration(days: 365)),
      gender: Gender.male,
      parentName: 'Parent',
      phoneNumber: '1234567890',
    );
    
    final now = DateTime.now();

    test('6 & 7 & 8. ChildProfile creation and all modules pending/not started', () {
      final profile = ChildProfile(
        child: child,
        milestoneResult: ModuleResult(module: 'milestone', childId: 'child_1', status: ModuleStatus.notStarted, updatedAt: now),
        growthResult: ModuleResult(module: 'growth', childId: 'child_1', status: ModuleStatus.notStarted, updatedAt: now),
        eyeTrackingResult: ModuleResult(module: 'eye_tracking', childId: 'child_1', status: ModuleStatus.pending, updatedAt: now),
        nutritionResult: ModuleResult(module: 'nutrition', childId: 'child_1', status: ModuleStatus.notStarted, updatedAt: now),
      );
      
      expect(profile.isFullyCompleted, false);
    });

    test('9. One module completed', () {
      final profile = ChildProfile(
        child: child,
        milestoneResult: ModuleResult(module: 'milestone', childId: 'child_1', status: ModuleStatus.completed, updatedAt: now),
        growthResult: ModuleResult(module: 'growth', childId: 'child_1', status: ModuleStatus.notStarted, updatedAt: now),
        eyeTrackingResult: ModuleResult(module: 'eye_tracking', childId: 'child_1', status: ModuleStatus.pending, updatedAt: now),
        nutritionResult: ModuleResult(module: 'nutrition', childId: 'child_1', status: ModuleStatus.notStarted, updatedAt: now),
      );
      expect(profile.isFullyCompleted, false);
    });

    test('10. Two modules completed', () {
      final profile = ChildProfile(
        child: child,
        milestoneResult: ModuleResult(module: 'milestone', childId: 'child_1', status: ModuleStatus.completed, updatedAt: now),
        growthResult: ModuleResult(module: 'growth', childId: 'child_1', status: ModuleStatus.completed, updatedAt: now),
        eyeTrackingResult: ModuleResult(module: 'eye_tracking', childId: 'child_1', status: ModuleStatus.completed, updatedAt: now),
        nutritionResult: ModuleResult(module: 'nutrition', childId: 'child_1', status: ModuleStatus.notStarted, updatedAt: now),
      );
      expect(profile.isFullyCompleted, false);
    });

    test('11. All modules completed', () {
      final profile = ChildProfile(
        child: child,
        milestoneResult: ModuleResult(module: 'milestone', childId: 'child_1', status: ModuleStatus.completed, updatedAt: now),
        growthResult: ModuleResult(module: 'growth', childId: 'child_1', status: ModuleStatus.completed, updatedAt: now),
        eyeTrackingResult: ModuleResult(module: 'eye_tracking', childId: 'child_1', status: ModuleStatus.completed, updatedAt: now),
        nutritionResult: ModuleResult(module: 'nutrition', childId: 'child_1', status: ModuleStatus.completed, updatedAt: now),
      );
      expect(profile.isFullyCompleted, true);
    });

    test('12 & 14. One module failed & childId consistency', () {
      final profile = ChildProfile(
        child: child,
        milestoneResult: ModuleResult(module: 'milestone', childId: 'child_1', status: ModuleStatus.completed, updatedAt: now),
        growthResult: ModuleResult(module: 'growth', childId: 'child_1', status: ModuleStatus.completed, updatedAt: now),
        eyeTrackingResult: ModuleResult(module: 'eye_tracking', childId: 'child_1', status: ModuleStatus.failed, updatedAt: now),
        nutritionResult: ModuleResult(module: 'nutrition', childId: 'child_1', status: ModuleStatus.completed, updatedAt: now),
      );
      expect(profile.isFullyCompleted, false);
      expect(profile.milestoneResult?.childId, child.id);
      expect(profile.eyeTrackingResult?.childId, child.id);
    });
  });

  group('DashboardProvider & Persistence Tests', () {
    late LocalStorageService storage;
    late ChildProvider childProvider;
    late DashboardProvider dashboardProvider;
    
    final child = Child(
      id: 'child_1',
      name: 'Test Child',
      dateOfBirth: DateTime.now().subtract(const Duration(days: 365)),
      gender: Gender.male,
      parentName: 'Parent',
      phoneNumber: '1234567890',
    );

    setUp(() async {
      storage = LocalStorageService();
      await storage.init();
      childProvider = ChildProvider(storageService: storage);
      dashboardProvider = DashboardProvider()
        ..updateDependencies(storageService: storage, childProvider: childProvider);
    });

    test('13 & 15. Milestone AssessmentResult -> ModuleResult conversion and aggregation', () async {
      await storage.saveChild(child);
      await storage.saveActiveChildId(child.id);
      
      // Save an AssessmentResult
      final assessmentResult = AssessmentResult(
        module: 'milestone',
        status: 'completed',
        childId: child.id,
        sessionId: 'session_1',
        ageGroup: AgeGroup.tenToTwelveMonths,
        referralRequired: false,
        scoredAt: DateTime.now(),
      );
      await storage.saveAssessmentResult(assessmentResult);
      
      // Reload the active child
      childProvider = ChildProvider(
        storageService: storage, 
        initialChild: storage.getChild(child.id),
      );
      dashboardProvider.updateDependencies(storageService: storage, childProvider: childProvider);
      
      // The dashboard provider loads async, wait for it
      await dashboardProvider.refresh();
      
      final profile = dashboardProvider.currentProfile;
      expect(profile, isNotNull);
      expect(profile!.milestoneResult?.status, ModuleStatus.completed);
      expect(profile.milestoneResult?.module, 'milestone');
    });

    test('16 & 20. Missing module results and partial completion', () async {
      await storage.saveChild(child);
      await storage.saveActiveChildId(child.id);
      
      childProvider = ChildProvider(
        storageService: storage, 
        initialChild: storage.getChild(child.id),
      );
      dashboardProvider.updateDependencies(storageService: storage, childProvider: childProvider);
      
      await dashboardProvider.refresh();
      
      final profile = dashboardProvider.currentProfile;
      // Milestone missing so notStarted
      expect(profile!.milestoneResult?.status, ModuleStatus.notStarted);
      // Eye Tracking & Nutrition missing so notStarted
      expect(profile.growthResult?.status, ModuleStatus.notStarted);
      expect(profile.eyeTrackingResult?.status, ModuleStatus.notStarted);
      expect(profile.nutritionResult?.status, ModuleStatus.notStarted);
      expect(profile.isFullyCompleted, false);
    });

    test('17 & 18. Local persistence and restart behavior', () async {
      await storage.saveChild(child);
      await storage.saveActiveChildId(child.id);
      
      final nutritionResult = ModuleResult(
        module: 'nutrition',
        childId: child.id,
        status: ModuleStatus.completed,
        updatedAt: DateTime.now(),
      );
      await storage.saveModuleResult(nutritionResult);
      
      // Simulate restart
      final newStorage = LocalStorageService();
      await newStorage.init();
      
      final activeId = newStorage.getActiveChildId();
      final newChildProvider = ChildProvider(
        storageService: newStorage,
        initialChild: activeId != null ? newStorage.getChild(activeId) : null,
      );
      
      final newDashboardProvider = DashboardProvider()
        ..updateDependencies(storageService: newStorage, childProvider: newChildProvider);
        
      await newDashboardProvider.refresh();
      
      final profile = newDashboardProvider.currentProfile;
      expect(profile!.child.id, child.id);
      expect(profile.nutritionResult?.status, ModuleStatus.completed);
      expect(profile.milestoneResult?.status, ModuleStatus.notStarted);
    });

    test('19. Corrupted stored data handling', () async {
      await storage.saveChild(child);
      await storage.saveActiveChildId(child.id);
      
      // Simulate corrupted shared prefs
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('mod_res_child_1_nutrition', 'INVALID_JSON__{');
      
      childProvider = ChildProvider(
        storageService: storage, 
        initialChild: storage.getChild(child.id),
      );
      dashboardProvider.updateDependencies(storageService: storage, childProvider: childProvider);
      
      await dashboardProvider.refresh();
      
      final profile = dashboardProvider.currentProfile;
      // Should gracefully fall back to notStarted due to try/catch
      expect(profile!.nutritionResult?.status, ModuleStatus.notStarted);
    });
  });
}
