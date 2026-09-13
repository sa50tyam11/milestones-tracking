import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/dashboard_provider.dart';
import '../../core/constants/enums.dart';
import '../../widgets/module_status_card.dart';

class FinalDashboardScreen extends StatelessWidget {
  const FinalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Dashboard'),
      ),
      body: SafeArea(
        child: Consumer<DashboardProvider>(
          builder: (context, dashboard, child) {
            if (dashboard.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final profile = dashboard.currentProfile;
            
            if (profile == null) {
              return const Center(
                child: Text(AppStrings.labelNoData),
              );
            }

            final activeChild = profile.child;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Child Profile Section
                  _buildSectionHeader(context, 'Child Profile'),
                  Card(
                    elevation: 0,
                    color: AppColors.neutralLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeChild.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text('Age: ${activeChild.displayAge}'),
                          Text('ID: ${activeChild.id}', 
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 2. Assessment Modules Section
                  _buildSectionHeader(context, 'Assessment Modules'),
                  
                  // Milestone Module
                  ModuleStatusCard(
                    title: 'Milestone Assessment',
                    status: profile.milestoneResult?.status ?? ModuleStatus.notStarted,
                    icon: Icons.child_care,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.milestoneAssessment);
                    },
                  ),

                  // Growth Monitoring Module
                  ModuleStatusCard(
                    title: 'Growth Monitoring',
                    status: profile.growthResult?.status ?? ModuleStatus.notStarted,
                    icon: Icons.show_chart,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.growth);
                    },
                  ),

                  // Vaccination Module
                  ModuleStatusCard(
                    title: 'Vaccination Schedule',
                    status: profile.vaccinationResult?.status ?? ModuleStatus.notStarted,
                    icon: Icons.vaccines,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.vaccination);
                    },
                  ),

                  // Eye Tracking Module
                  ModuleStatusCard(
                    title: 'Eye Tracking (NeuroGaze)',
                    status: profile.eyeTrackingResult?.status ?? ModuleStatus.notStarted,
                    icon: Icons.remove_red_eye,
                    onTap: () {
                      // Navigate to Eye Tracking later
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Eye Tracking module pending integration')),
                      );
                    },
                  ),

                  // Nutrition Module
                  ModuleStatusCard(
                    title: 'Nutrition (VitaScan)',
                    status: profile.nutritionResult?.status ?? ModuleStatus.notStarted,
                    icon: Icons.restaurant,
                    onTap: () {
                      // Navigate to Nutrition later
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nutrition module pending integration')),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // 3. Overall Assessment Section
                  _buildSectionHeader(context, 'Overall Assessment'),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: profile.isFullyCompleted 
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: profile.isFullyCompleted 
                            ? AppColors.success.withValues(alpha: 0.3)
                            : AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          profile.isFullyCompleted 
                              ? Icons.check_circle
                              : Icons.hourglass_empty,
                          color: profile.isFullyCompleted 
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            profile.isFullyCompleted 
                                ? 'All Module Assessments Completed'
                                : 'Screening Pending',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: profile.isFullyCompleted 
                                      ? AppColors.success
                                      : AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
      ),
    );
  }
}
