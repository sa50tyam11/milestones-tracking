import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/assessment_session.dart';

/// Temporary completion screen for Phase 7.
/// Receives the AssessmentSession as a route argument and displays a success message.
class AssessmentCompleteScreen extends StatelessWidget {
  const AssessmentCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Read the passed session from route arguments.
    // We do not display the session contents here yet, as clinical scoring
    // belongs to Phase 8+. We just need to receive it to prove it exists.
    final session = ModalRoute.of(context)?.settings.arguments as AssessmentSession?;

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
                'Scoring and personalized results will be available in a later module.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              if (session != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.neutralLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Session ID: ${session.sessionId}\nAnswered: ${session.totalAnswered}',
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
