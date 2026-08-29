import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/child_provider.dart';

/// Minimal Home screen acting as a placeholder landing zone after registration.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navHome),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Consumer<ChildProvider>(
            builder: (context, childProvider, child) {
              final activeChild = childProvider.currentChild;
              
              if (activeChild == null) {
                return const Center(
                  child: Text(AppStrings.labelNoData),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: AppColors.success),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppStrings.homeRegistrationSuccess,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '${AppStrings.homeWelcome}, ${activeChild.parentName}!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Active profile: ${activeChild.name} (${activeChild.displayAge})',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const Spacer(),
                  // Placeholder for Assessment entry point
                  ElevatedButton.icon(
                    onPressed: () {
                      // Will navigate to MilestoneAssessment in Phase 8
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Assessment module coming soon.')),
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text(AppStrings.homeStartAssessment),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
