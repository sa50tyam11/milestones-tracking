import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/assessment_result.dart';

/// Temporary completion screen for Phase 8B.
/// Receives the AssessmentResult as a route argument and displays the outcome.
class AssessmentCompleteScreen extends StatelessWidget {
  const AssessmentCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Read the passed result from route arguments.
    final result = ModalRoute.of(context)?.settings.arguments as AssessmentResult?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Complete'),
        // Prevent going back to the assessment
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: AppColors.success,
              ),
              const SizedBox(height: 32),
              Text(
                'Assessment submitted',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Your responses have been recorded.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Clinical interpretation is pending until scoring rules are established.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              if (result != null) ...[
                const SizedBox(height: 24),
                if (result.referralRequired)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.errorSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Referral Indicated',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppColors.error,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'A critical milestone was missed. Please consult a healthcare professional.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.neutralLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Session ID: ${result.sessionId}\nStatus: ${result.status}',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  // Return to Home, clearing the assessment stack
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.home,
                    (route) => false,
                  );
                },
                child: const Text('Return to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
