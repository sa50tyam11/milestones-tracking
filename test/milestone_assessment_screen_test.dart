import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:child_health_screening/core/constants/enums.dart';
import 'package:child_health_screening/models/child.dart';
import 'package:child_health_screening/models/milestone.dart';
import 'package:child_health_screening/providers/child_provider.dart';
import 'package:child_health_screening/providers/milestone_provider.dart';
import 'package:child_health_screening/repositories/milestone_repository.dart';
import 'package:child_health_screening/services/milestone_service.dart';
import 'package:child_health_screening/screens/milestone/milestone_assessment_screen.dart';
import 'package:child_health_screening/core/routes/app_routes.dart';
import 'package:child_health_screening/screens/milestone/assessment_complete_screen.dart';

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
  Milestone createTestMilestone(String id, AgeGroup ageGroup, String question) {
    return Milestone(
      id: id,
      ageGroup: ageGroup,
      domain: DevelopmentDomain.grossMotor,
      title: 'Test $id',
      description: 'Desc',
      instruction: 'Inst',
      question: question,
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

  Widget createAssessmentScreen(ChildProvider childProvider, MilestoneProvider milestoneProvider) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: childProvider),
        ChangeNotifierProvider.value(value: milestoneProvider),
      ],
      child: MaterialApp(
        routes: {
          AppRoutes.milestoneResult: (_) => const AssessmentCompleteScreen(),
        },
        home: const MilestoneAssessmentScreen(),
      ),
    );
  }

  group('Milestone Assessment Screen Tests', () {
    late ChildProvider childProvider;
    late MilestoneProvider milestoneProvider;
    late MilestoneRepository repository;
    late FakeMilestoneService fakeService;

    setUp(() {
      childProvider = ChildProvider();
      
      fakeService = FakeMilestoneService(mockMilestones: [
        createTestMilestone('m_2mo_1', AgeGroup.twoToThreeMonths, 'Question 1?'),
        createTestMilestone('m_2mo_2', AgeGroup.twoToThreeMonths, 'Question 2?'),
      ]);
      
      repository = MilestoneRepository(service: fakeService);
      
      milestoneProvider = MilestoneProvider();
      milestoneProvider.updateDependencies(
        repository: repository,
        childProvider: childProvider,
      );
    });

    testWidgets('1. Screen opens and displays No Child error if missing', (WidgetTester tester) async {
      await tester.pumpWidget(createAssessmentScreen(childProvider, milestoneProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Please register a child before starting an assessment.'), findsOneWidget);
    });

    testWidgets('4. Milestones loaded, 5. First milestone displayed, 6. Child name displayed', (WidgetTester tester) async {
      childProvider.setChild(createChildWithAge(2));
      await tester.pumpWidget(createAssessmentScreen(childProvider, milestoneProvider));
      // wait for initState to trigger load
      await tester.pumpAndSettle();
      
      // Verification
      expect(find.text('Child: Test Child'), findsOneWidget);
      expect(find.text('Question 1 of 2'), findsOneWidget);
      expect(find.text('Question 1?'), findsOneWidget);
    });

    testWidgets('7-11. Answer records and Next advances', (WidgetTester tester) async {
      childProvider.setChild(createChildWithAge(2));
      await tester.pumpWidget(createAssessmentScreen(childProvider, milestoneProvider));
      await tester.pumpAndSettle();

      final nextBtn = find.text('Next');
      final elevatedButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Next'));
      
      // 10. Next blocked without answer
      expect(elevatedButton.onPressed, isNull);

      // 7. Yes response
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
      
      expect(milestoneProvider.answers.containsKey('m_2mo_1'), isTrue);
      expect(milestoneProvider.answers['m_2mo_1']?.response, AssessmentResponse.yes);

      // 11. Next advances after answer
      final enabledElevatedButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Next'));
      expect(enabledElevatedButton.onPressed, isNotNull);
      
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();
      
      expect(find.text('Question 2 of 2'), findsOneWidget);
      expect(find.text('Question 2?'), findsOneWidget);
    });

    testWidgets('12-14. Back works, preserves answers, change replaces old', (WidgetTester tester) async {
      childProvider.setChild(createChildWithAge(2));
      await tester.pumpWidget(createAssessmentScreen(childProvider, milestoneProvider));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();

      // We are on Question 2
      expect(find.text('Question 2?'), findsOneWidget);
      
      // 12. Back works
      await tester.tap(find.widgetWithText(OutlinedButton, 'Back'));
      await tester.pumpAndSettle();
      
      // We are back to Question 1
      expect(find.text('Question 1?'), findsOneWidget);
      
      // 14. Change answer (No response)
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();
      
      expect(milestoneProvider.answers['m_2mo_1']?.response, AssessmentResponse.no);
    });

    testWidgets('16-20. Final question enters Review and Submission works', (WidgetTester tester) async {
      childProvider.setChild(createChildWithAge(2));
      await tester.pumpWidget(createAssessmentScreen(childProvider, milestoneProvider));
      await tester.pumpAndSettle();

      // Q1
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();

      // Q2
      await tester.tap(find.text('Not Sure'));
      await tester.pumpAndSettle();
      
      // 16. Final question changes Next to Review
      await tester.tap(find.widgetWithText(ElevatedButton, 'Review'));
      await tester.pumpAndSettle();
      
      // 17. Review shows answers
      expect(find.text('Assessment Review'), findsOneWidget);
      expect(find.text('All Questions Answered'), findsOneWidget);
      expect(find.text('2 of 2 completed'), findsOneWidget);
      
      // 18. User can edit from Review
      expect(find.widgetWithText(OutlinedButton, 'Back to Edit'), findsOneWidget);
      
      // 19. Submission
      await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Assessment'));
      await tester.pumpAndSettle();
      
      // 20. Completion screen appears
      expect(find.text('Assessment Complete'), findsOneWidget);
      expect(find.text('Assessment submitted'), findsOneWidget);
    });
  });
}
