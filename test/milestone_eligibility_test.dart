import 'package:flutter_test/flutter_test.dart';
import 'package:child_health_screening/models/child.dart';
import 'package:child_health_screening/core/constants/enums.dart';
import 'package:child_health_screening/models/milestone.dart';
import 'package:child_health_screening/providers/child_provider.dart';
import 'package:child_health_screening/providers/milestone_provider.dart';
import 'package:child_health_screening/repositories/milestone_repository.dart';
import 'package:child_health_screening/services/milestone_service.dart';

class FakeMilestoneService extends MilestoneService {
  final List<Milestone> _mockMilestones;
  
  FakeMilestoneService({List<Milestone>? mockMilestones}) 
    : _mockMilestones = mockMilestones ?? [];

  @override
  bool get isInitialised => true;

  @override
  List<Milestone> getMilestonesForAgeGroup(AgeGroup ageGroup) {
    return _mockMilestones.where((m) => m.ageGroup == ageGroup).toList();
  }
}

void main() {
  Milestone createTestMilestone(String id, AgeGroup ageGroup) {
    return Milestone(
      id: id,
      ageGroup: ageGroup,
      domain: DevelopmentDomain.grossMotor,
      title: 'Test $id',
      description: 'Desc',
      instruction: 'Inst',
      question: 'Q?',
      isCritical: false,
      mediaType: MediaType.none,
      requiresAI: false,
      difficulty: MilestoneDifficulty.foundational,
      estimatedTimeSeconds: 30,
      source: 'WHO',
      order: 1,
    );
  }

  Child createChildWithAge(int ageInMonths) {
    final now = DateTime.now();
    return Child(
      id: 'test_child_1',
      name: 'Test Child',
      dateOfBirth: DateTime(now.year, now.month - ageInMonths, now.day),
      gender: Gender.female,
      parentName: 'Caregiver',
      phoneNumber: '1234567890',
    );
  }

  group('Phase 6: Milestone Eligibility Data Flow', () {
    late ChildProvider childProvider;
    late MilestoneProvider milestoneProvider;
    late MilestoneRepository repository;
    late FakeMilestoneService fakeService;

    setUp(() {
      childProvider = ChildProvider();
      
      // Populate service with some milestones for 2-3 months and 4-6 months
      fakeService = FakeMilestoneService(mockMilestones: [
        createTestMilestone('m_2mo', AgeGroup.twoToThreeMonths),
        createTestMilestone('m_4mo', AgeGroup.fourToSixMonths),
      ]);
      
      repository = MilestoneRepository(service: fakeService);
      
      milestoneProvider = MilestoneProvider();
      milestoneProvider.updateDependencies(
        repository: repository,
        childProvider: childProvider,
      );
    });

    test('valid age loads corresponding milestones', () {
      // 2 months old belongs to AgeGroup.months2
      childProvider.setChild(createChildWithAge(2));
      
      // Provider loading
      milestoneProvider.loadMilestonesForCurrentChild();
      
      // Verification
      expect(milestoneProvider.state, AssessmentState.inProgress);
      expect(milestoneProvider.currentMilestones.length, 1);
      expect(milestoneProvider.currentMilestones.first.id, 'm_2mo');
    });

    test('unsupported age (too young) sets error state', () {
      // 1 month old is not supported (no AgeGroup)
      childProvider.setChild(createChildWithAge(1));
      
      milestoneProvider.loadMilestonesForCurrentChild();
      
      expect(milestoneProvider.state, AssessmentState.error);
      expect(milestoneProvider.errorMessage, contains('outside the supported'));
      expect(milestoneProvider.currentMilestones, isEmpty);
    });

    test('unsupported age (too old) sets error state', () {
      // 61 months old is not supported
      childProvider.setChild(createChildWithAge(61));
      
      milestoneProvider.loadMilestonesForCurrentChild();
      
      expect(milestoneProvider.state, AssessmentState.error);
      expect(milestoneProvider.errorMessage, contains('outside the supported'));
      expect(milestoneProvider.currentMilestones, isEmpty);
    });

    test('empty result (supported age but no milestones found) sets error state', () {
      // 60 months old belongs to AgeGroup.months48
      // FakeService doesn't have any milestones for months48
      childProvider.setChild(createChildWithAge(60));
      
      milestoneProvider.loadMilestonesForCurrentChild();
      
      expect(milestoneProvider.state, AssessmentState.error);
      expect(milestoneProvider.errorMessage, equals('No milestones found for this age group.'));
      expect(milestoneProvider.currentMilestones, isEmpty);
    });

    test('provider loading error if no child is selected', () {
      // We explicitly don't set a child in childProvider
      milestoneProvider.loadMilestonesForCurrentChild();
      
      expect(milestoneProvider.state, AssessmentState.error);
      expect(milestoneProvider.errorMessage, equals('No child selected.'));
    });
  });
}
