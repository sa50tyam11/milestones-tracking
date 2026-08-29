import 'package:flutter_test/flutter_test.dart';
import 'package:child_health_screening/models/child.dart';
import 'package:child_health_screening/models/milestone.dart';
import 'package:child_health_screening/core/constants/enums.dart';
import 'package:child_health_screening/repositories/milestone_repository.dart';
import 'package:child_health_screening/services/milestone_service.dart';
import 'package:child_health_screening/providers/child_provider.dart';
import 'package:child_health_screening/providers/milestone_provider.dart';

// ---------------------------------------------------------------------------
// Fake Service for testing
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Child createTestChild({required int ageInMonths}) {
  final now = DateTime.now();
  return Child(
    id: 'test_child_1',
    name: 'Test Baby',
    dateOfBirth: DateTime(now.year, now.month - ageInMonths, now.day),
    gender: Gender.female,
    parentName: 'Test Parent',
    phoneNumber: '1234567890',
    vaccinationStatus: VaccinationStatus.upToDate,
  );
}

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

void main() {
  group('ChildProvider', () {
    late ChildProvider childProvider;

    setUp(() {
      childProvider = ChildProvider();
    });

    test('1. starts empty', () {
      expect(childProvider.currentChild, isNull);
      expect(childProvider.hasChild, isFalse);
    });

    test('2. can be selected/created', () {
      final child = createTestChild(ageInMonths: 6);
      childProvider.setChild(child);

      expect(childProvider.currentChild, equals(child));
      expect(childProvider.hasChild, isTrue);
    });

    test('3. can be cleared', () {
      final child = createTestChild(ageInMonths: 6);
      childProvider.setChild(child);
      childProvider.clearChild();

      expect(childProvider.currentChild, isNull);
      expect(childProvider.hasChild, isFalse);
    });

    test('can update child details', () {
      final child = createTestChild(ageInMonths: 6);
      childProvider.setChild(child);

      final updatedChild = child.copyWith(weightKg: 8.5);
      childProvider.updateChild(updatedChild);

      expect(childProvider.currentChild?.weightKg, equals(8.5));
    });
  });

  group('MilestoneProvider', () {
    late ChildProvider childProvider;
    late MilestoneProvider milestoneProvider;
    late MilestoneRepository repository;
    late FakeMilestoneService fakeService;

    final mockMilestones = [
      createTestMilestone('m1', AgeGroup.fourToSixMonths),
      createTestMilestone('m2', AgeGroup.fourToSixMonths),
    ];

    setUp(() {
      childProvider = ChildProvider();
      fakeService = FakeMilestoneService(mockMilestones: mockMilestones);
      repository = MilestoneRepository(service: fakeService);

      milestoneProvider = MilestoneProvider();
      milestoneProvider.updateDependencies(
        repository: repository,
        childProvider: childProvider,
      );
    });

    test('4. initial state', () {
      expect(milestoneProvider.state, equals(AssessmentState.initial));
      expect(milestoneProvider.currentMilestones, isEmpty);
      expect(milestoneProvider.answers, isEmpty);
      expect(milestoneProvider.progress, equals(0.0));
    });

    test('5, 6, 7. loading, successful retrieval, inProgress state', () {
      // 6 month old child belongs to fourToSixMonths
      childProvider.setChild(createTestChild(ageInMonths: 6));
      
      milestoneProvider.loadMilestonesForCurrentChild();

      expect(milestoneProvider.state, equals(AssessmentState.inProgress));
      expect(milestoneProvider.currentMilestones.length, equals(2));
    });

    test('8, 9. Empty milestone result / error handling (Age out of bounds)', () {
      // 1 month old is not supported (supported starts at 2 months)
      childProvider.setChild(createTestChild(ageInMonths: 1));
      
      milestoneProvider.loadMilestonesForCurrentChild();

      expect(milestoneProvider.state, equals(AssessmentState.error));
      expect(milestoneProvider.errorMessage, contains('outside the supported'));
    });

    test('error handling (No child selected)', () {
      // Don't set a child
      milestoneProvider.loadMilestonesForCurrentChild();

      expect(milestoneProvider.state, equals(AssessmentState.error));
      expect(milestoneProvider.errorMessage, equals('No child selected.'));
    });

    test('10. answer recording', () {
      childProvider.setChild(createTestChild(ageInMonths: 6));
      milestoneProvider.loadMilestonesForCurrentChild();

      milestoneProvider.recordAnswer('m1', AssessmentAnswer.yes);

      expect(milestoneProvider.answers.containsKey('m1'), isTrue);
      expect(milestoneProvider.answers['m1'], equals(AssessmentAnswer.yes));
    });

    test('11. answer updating', () {
      childProvider.setChild(createTestChild(ageInMonths: 6));
      milestoneProvider.loadMilestonesForCurrentChild();

      milestoneProvider.recordAnswer('m1', AssessmentAnswer.yes);
      milestoneProvider.recordAnswer('m1', AssessmentAnswer.no); // Change answer

      expect(milestoneProvider.answers['m1'], equals(AssessmentAnswer.no));
    });

    test('12. answer clearing', () {
      childProvider.setChild(createTestChild(ageInMonths: 6));
      milestoneProvider.loadMilestonesForCurrentChild();
      milestoneProvider.recordAnswer('m1', AssessmentAnswer.yes);

      milestoneProvider.clearAnswers();

      expect(milestoneProvider.answers, isEmpty);
      expect(milestoneProvider.state, equals(AssessmentState.inProgress));
    });

    test('13. progress calculation', () {
      childProvider.setChild(createTestChild(ageInMonths: 6));
      milestoneProvider.loadMilestonesForCurrentChild(); // loads 2 milestones

      expect(milestoneProvider.progress, equals(0.0));

      milestoneProvider.recordAnswer('m1', AssessmentAnswer.yes);
      expect(milestoneProvider.progress, equals(0.5));

      milestoneProvider.recordAnswer('m2', AssessmentAnswer.no);
      expect(milestoneProvider.progress, equals(1.0));
    });

    test('14. completion detection', () {
      childProvider.setChild(createTestChild(ageInMonths: 6));
      milestoneProvider.loadMilestonesForCurrentChild();

      milestoneProvider.recordAnswer('m1', AssessmentAnswer.yes);
      expect(milestoneProvider.state, equals(AssessmentState.inProgress));

      milestoneProvider.recordAnswer('m2', AssessmentAnswer.no);
      expect(milestoneProvider.state, equals(AssessmentState.completed));
    });
  });
}
