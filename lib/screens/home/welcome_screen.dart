import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';

/// The Welcome / onboarding screen shown after Splash.
///
/// ## Purpose
/// 1. Introduce the application to first-time users.
/// 2. Communicate the app's purpose in simple, non-clinical language.
/// 3. Display the mandatory screening disclaimer.
/// 4. Provide the "Get Started" call-to-action that begins registration.
///
/// ## Navigation
/// - Forward: "Get Started" → Registration ([AppRoutes.registration])
/// - Back: Pressing device back exits the app (Splash was replaced, not stacked)
///
/// ## Medical language compliance
/// The disclaimer text in this screen uses only screening language.
/// It must never claim the app provides a medical diagnosis.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Hero section — fills top half of screen
            Expanded(
              child: _HeroSection(textTheme: textTheme),
            ),

            // Bottom action section
            _ActionSection(textTheme: textTheme),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero section — illustration + headline
// ---------------------------------------------------------------------------

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration placeholder — replace with real SVG in Phase 25
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.child_care,
              size: 72,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 32),

          // App name — small label above the headline
          Text(
            AppStrings.appName,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          // Main headline
          Text(
            AppStrings.welcomeTitle,
            textAlign: TextAlign.center,
            style: textTheme.headlineLarge?.copyWith(
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 16),

          // Subtitle / purpose statement
          Text(
            AppStrings.welcomeSubtitle,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 24),

          // Feature highlights — 3 brief points
          _FeatureRow(
            icon: Icons.track_changes_rounded,
            text: 'Track developmental milestones',
          ),
          const SizedBox(height: 10),
          _FeatureRow(
            icon: Icons.vaccines_rounded,
            text: 'Monitor vaccination schedule',
          ),
          const SizedBox(height: 10),
          _FeatureRow(
            icon: Icons.monitor_heart_rounded,
            text: 'Nutritional & growth screening',
          ),
        ],
      ),
    );
  }
}

/// A single feature highlight row with an icon and label.
class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Action section — disclaimer + buttons
// ---------------------------------------------------------------------------

class _ActionSection extends StatelessWidget {
  const _ActionSection({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Disclaimer — REQUIRED for medical compliance
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppStrings.welcomeDisclaimer,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryDark,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Primary CTA
          ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.registration),
            child: const Text(AppStrings.welcomeGetStarted),
          ),
        ],
      ),
    );
  }
}
