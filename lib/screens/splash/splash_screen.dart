import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';

/// The application entry screen.
///
/// ## Responsibilities
/// 1. Display the ShishuCare brand while the app initializes.
/// 2. Wait for a short display period so the user can orient themselves.
/// 3. Navigate to [WelcomeScreen] using [Navigator.pushReplacementNamed]
///    so the user cannot navigate back to the splash screen.
///
/// ## Why pushReplacementNamed?
/// Regular [Navigator.pushNamed] keeps Splash in the back stack.
/// If the user presses Back from Welcome, they'd return to Splash again.
/// [pushReplacementNamed] removes Splash from the stack entirely —
/// pressing Back from Welcome exits the app instead.
///
/// ## MilestoneService initialization
/// MilestoneService is initialized in main() BEFORE runApp() is called.
/// By the time SplashScreen builds, the service is already ready.
/// The splash delay exists purely for user experience — not for loading.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Duration the splash screen remains visible before navigating.
  // 2 seconds is standard — enough to read the app name, not long enough
  // to feel like a wait.
  static const Duration _splashDuration = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  /// Waits for [_splashDuration] then navigates to the Welcome screen.
  ///
  /// Uses [mounted] check before navigation — if the widget is removed
  /// from the tree before the timer fires (e.g. during hot restart),
  /// calling Navigator on an unmounted widget would throw an error.
  Future<void> _navigateAfterDelay() async {
    await Future.delayed(_splashDuration);
    if (!mounted) return;
    await Navigator.pushReplacementNamed(context, AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App icon placeholder — replace with actual logo asset in Phase 25
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.child_care,
                  size: 52,
                  color: AppColors.textOnPrimary,
                ),
              ),
              const SizedBox(height: 28),

              // App name
              Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 10),

              // Tagline
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  AppStrings.appTagline,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textOnPrimary.withValues(alpha: 0.85),
                        height: 1.5,
                      ),
                ),
              ),
              const SizedBox(height: 60),

              // Loading indicator — subtle, not distracting
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.textOnPrimary.withValues(alpha: 0.7),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                AppStrings.splashLoading,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.6),
                    ),
              ),
            ],
          ),
        ),
      ),
      // BioMed Bharat attribution at the bottom
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Text(
            AppStrings.splashPoweredBy,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.5),
                  letterSpacing: 0.5,
                ),
          ),
        ),
      ),
    );
  }
}
