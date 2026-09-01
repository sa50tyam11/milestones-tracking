import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/enums.dart';
import '../../core/routes/app_routes.dart';
import '../../models/milestone.dart';
import '../../models/assessment_session.dart';
import '../../providers/child_provider.dart';
import '../../providers/milestone_provider.dart';

class MilestoneAssessmentScreen extends StatefulWidget {
  const MilestoneAssessmentScreen({super.key});

  @override
  State<MilestoneAssessmentScreen> createState() => _MilestoneAssessmentScreenState();
}

class _MilestoneAssessmentScreenState extends State<MilestoneAssessmentScreen> {
  int _currentIndex = 0;
  DateTime? _startedAt;
  bool _isReviewMode = false;
  bool _initiallyLoaded = false;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to safely access Provider context after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAssessment();
    });
  }

  void _initializeAssessment() {
    if (!mounted) return;
    final childProvider = context.read<ChildProvider>();
    final milestoneProvider = context.read<MilestoneProvider>();

    if (!childProvider.hasChild) {
      // Handled in the build method (No active child state)
      return;
    }

    _startedAt = DateTime.now();
    milestoneProvider.loadMilestonesForCurrentChild();
    setState(() {
      _initiallyLoaded = true;
    });
  }

  void _handleNext() {
    final milestoneProvider = context.read<MilestoneProvider>();
    final milestones = milestoneProvider.currentMilestones;

    if (_currentIndex < milestones.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      // End of questions, enter Review mode
      setState(() {
        _isReviewMode = true;
      });
    }
  }

  void _handleBack() {
    if (_isReviewMode) {
      setState(() {
        _isReviewMode = false;
      });
    } else if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    } else {
      // First question -> back exits the assessment
      Navigator.of(context).pop();
    }
  }

  void _submitAssessment() {
    final milestoneProvider = context.read<MilestoneProvider>();
    final childProvider = context.read<ChildProvider>();

    final session = AssessmentSession(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(), // MVP session ID
      childId: childProvider.currentChild!.id,
      ageGroup: childProvider.currentChild!.ageGroup!,
      answers: milestoneProvider.answers,
      startedAt: _startedAt ?? DateTime.now(),
      completedAt: DateTime.now(),
    );

    // Navigate to completion and pass the session
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.milestoneResult,
      arguments: session,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Milestone Assessment'),
        leading: BackButton(onPressed: _handleBack),
      ),
      body: Consumer2<ChildProvider, MilestoneProvider>(
        builder: (context, childProvider, milestoneProvider, _) {
          if (!childProvider.hasChild) {
            return _buildErrorState('Please register a child before starting an assessment.');
          }

          if (!_initiallyLoaded || milestoneProvider.state == AssessmentState.initial || milestoneProvider.state == AssessmentState.loading) {
            return _buildLoadingState();
          }

          if (milestoneProvider.state == AssessmentState.error) {
            return _buildErrorState(milestoneProvider.errorMessage ?? AppStrings.labelError);
          }

          final milestones = milestoneProvider.currentMilestones;
          if (milestones.isEmpty) {
            return _buildErrorState('No milestones found for this age group.');
          }

          if (_isReviewMode) {
            return _buildReviewState(milestoneProvider, milestones.length);
          }

          return _buildQuestionState(milestoneProvider, milestones);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(AppStrings.labelLoading),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Return to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionState(MilestoneProvider provider, List<Milestone> milestones) {
    final currentMilestone = milestones[_currentIndex];
    final currentAnswer = provider.answers[currentMilestone.id];
    final child = context.read<ChildProvider>().currentChild!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Child: ${child.name}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Question ${_currentIndex + 1} of ${milestones.length}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: provider.progress,
              backgroundColor: AppColors.primarySurface,
            ),
            const SizedBox(height: 24),
            
            // Domain & Title
            Chip(
              label: Text(currentMilestone.domain.label),
            ),
            const SizedBox(height: 16),
            
            // Instruction Box (if any)
            if (currentMilestone.instruction.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primarySurface),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        currentMilestone.instruction,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // The Question
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      currentMilestone.question,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 32),

                    // Response Options
                    ...AssessmentResponse.values.map((response) {
                      final isSelected = currentAnswer?.response == response;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: InkWell(
                          onTap: () {
                            provider.recordAnswer(currentMilestone.id, response);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primarySurface : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.divider,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                  color: isSelected ? AppColors.primary : AppColors.neutral,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  response.label,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            
            // Navigation Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _handleBack,
                    child: const Text(AppStrings.buttonBack),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: currentAnswer == null ? null : _handleNext,
                    child: Text(_currentIndex == milestones.length - 1 ? 'Review' : AppStrings.buttonNext),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewState(MilestoneProvider provider, int totalMilestones) {
    final answeredCount = provider.answers.length;
    final isComplete = answeredCount == totalMilestones;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Assessment Review',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isComplete ? AppColors.successSurface : AppColors.warningSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isComplete ? AppColors.success : AppColors.warning,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isComplete ? Icons.check_circle : Icons.warning_amber_rounded,
                    color: isComplete ? AppColors.success : AppColors.warning,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isComplete ? 'All Questions Answered' : 'Incomplete Assessment',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$answeredCount of $totalMilestones completed',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _handleBack,
                    child: const Text('Back to Edit'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isComplete ? _submitAssessment : null,
                    child: const Text('Submit Assessment'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
