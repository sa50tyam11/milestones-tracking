// ShishuCare — Application smoke tests
//
// These tests verify the basic application shell introduced in Phase 2.
// Full unit, widget, and integration tests will be written in Phase 20.
//
// ## Why some tests use testWidgets instead of test()
// GoogleFonts requires WidgetsFlutterBinding to be initialized.
// Tests that use AppTheme.lightTheme must run inside testWidgets so the
// binding is active. Pure unit tests (AppColors, AppStrings) use test().

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:child_health_screening/core/constants/app_strings.dart';
import 'package:child_health_screening/core/constants/app_colors.dart';
import 'package:child_health_screening/core/theme/app_theme.dart';
import 'package:child_health_screening/screens/splash/splash_screen.dart';
import 'package:child_health_screening/screens/home/welcome_screen.dart';
import 'package:child_health_screening/screens/registration/registration_screen.dart';

void main() {
  setUpAll(() {
    // Disable runtime font fetching so tests don't make HTTP calls.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  // -------------------------------------------------------------------------
  // AppColors — pure unit tests, no binding needed
  // -------------------------------------------------------------------------
  group('AppColors', () {
    test('primary color is defined', () {
      expect(AppColors.primary, isA<Color>());
    });

    test('all semantic colors are defined', () {
      expect(AppColors.success, isA<Color>());
      expect(AppColors.warning, isA<Color>());
      expect(AppColors.error, isA<Color>());
    });

    test('riskLow equals success color', () {
      expect(AppColors.riskLow, equals(AppColors.success));
    });

    test('riskHigh equals error color', () {
      expect(AppColors.riskHigh, equals(AppColors.error));
    });

    test('textOnPrimary is white', () {
      expect(AppColors.textOnPrimary, equals(const Color(0xFFFFFFFF)));
    });
  });

  // -------------------------------------------------------------------------
  // AppStrings — pure unit tests, no binding needed
  // -------------------------------------------------------------------------
  group('AppStrings', () {
    test('app name is ShishuCare', () {
      expect(AppStrings.appName, equals('ShishuCare'));
    });

    test('welcome disclaimer states app does not provide diagnosis', () {
      final disclaimer = AppStrings.welcomeDisclaimer.toLowerCase();
      expect(
        disclaimer.contains('does not diagnose') ||
            disclaimer.contains('not a medical diagnosis') ||
            disclaimer.contains('not diagnose'),
        isTrue,
        reason: 'Disclaimer must explicitly state the app does not diagnose',
      );
    });

    test('screening disclaimer contains required language', () {
      final disclaimer = AppStrings.screeningDisclaimer.toLowerCase();
      expect(disclaimer.contains('screening'), isTrue);
      expect(disclaimer.contains('not a medical diagnosis'), isTrue);
    });

    test('all required strings are non-empty', () {
      expect(AppStrings.appName, isNotEmpty);
      expect(AppStrings.appTagline, isNotEmpty);
      expect(AppStrings.welcomeTitle, isNotEmpty);
      expect(AppStrings.welcomeGetStarted, isNotEmpty);
      expect(AppStrings.registrationTitle, isNotEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // AppTheme — requires testWidgets for WidgetsBinding
  // -------------------------------------------------------------------------
  group('AppTheme', () {
    testWidgets('lightTheme uses Material 3', (tester) async {
      expect(AppTheme.lightTheme.useMaterial3, isTrue);
    });

    testWidgets('scaffold background matches AppColors.background',
        (tester) async {
      expect(
        AppTheme.lightTheme.scaffoldBackgroundColor,
        equals(AppColors.background),
      );
    });

    testWidgets('primary color scheme matches AppColors.primary',
        (tester) async {
      expect(
        AppTheme.lightTheme.colorScheme.primary,
        equals(AppColors.primary),
      );
    });
  });

  // -------------------------------------------------------------------------
  // SplashScreen widget test
  // -------------------------------------------------------------------------
  group('SplashScreen', () {
    testWidgets('renders app name on screen', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SplashScreen(),
            routes: {'/welcome': (_) => const Scaffold(body: Text('Welcome'))},
          ),
        );
        // We only want to verify the splash renders before the delay finishes.
        expect(find.text(AppStrings.appName), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });
  });

  // -------------------------------------------------------------------------
  // WelcomeScreen widget tests
  // -------------------------------------------------------------------------
  group('WelcomeScreen', () {
    Widget buildWelcome() => MaterialApp(
          theme: AppTheme.lightTheme,
          home: const WelcomeScreen(),
          routes: {'/registration': (_) => const Scaffold(body: Text('Reg'))},
        );

    testWidgets('renders Get Started button', (tester) async {
      await tester.pumpWidget(buildWelcome());
      await tester.pump();
      expect(find.text(AppStrings.welcomeGetStarted), findsOneWidget);
    });

    testWidgets('shows disclaimer info icon', (tester) async {
      await tester.pumpWidget(buildWelcome());
      await tester.pump();
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });

    testWidgets('shows child_care icon', (tester) async {
      await tester.pumpWidget(buildWelcome());
      await tester.pump();
      expect(find.byIcon(Icons.child_care), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // RegistrationScreen widget tests
  // -------------------------------------------------------------------------
  group('RegistrationScreen', () {
    Widget buildRegistration() => MaterialApp(
          theme: AppTheme.lightTheme,
          home: const RegistrationScreen(),
        );

    testWidgets('renders registration title', (tester) async {
      await tester.pumpWidget(buildRegistration());
      await tester.pump();
      expect(find.text(AppStrings.registrationTitle), findsWidgets);
    });
  });
}
