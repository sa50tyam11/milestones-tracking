import 'package:flutter_test/flutter_test.dart';
import 'package:child_health_screening/models/child.dart';
import 'package:child_health_screening/core/constants/enums.dart';

void main() {
  /// Returns a DateTime that represents exactly [M] months ago from today.
  /// Handles month-length differences (e.g. going from Oct 31 to Sept 30).
  DateTime exactMonthsAgo(int M) {
    final now = DateTime.now();
    int y = now.year;
    int m = now.month - M;
    while (m <= 0) {
      y--;
      m += 12;
    }
    int d = now.day;
    int maxDays = DateTime(y, m + 1, 0).day;
    if (d > maxDays) d = maxDays;
    return DateTime(y, m, d);
  }

  /// Returns a DOB that means the child will be exactly [M] months old TOMORROW.
  /// (i.e. they are [M] - 1 months old today).
  DateTime oneDayBeforeExact(int M) {
    final exact = exactMonthsAgo(M);
    return DateTime(exact.year, exact.month, exact.day + 1);
  }

  /// Returns a DOB that means the child was exactly [M] months old YESTERDAY.
  /// (i.e. they are [M] months and 1 day old today, so ageInMonths is still [M]).
  DateTime oneDayAfterExact(int M) {
    final exact = exactMonthsAgo(M);
    return DateTime(exact.year, exact.month, exact.day - 1);
  }

  Child createChild(DateTime dob) {
    return Child(
      id: 'test_child',
      name: 'Test Child',
      dateOfBirth: dob,
      gender: Gender.male,
      parentName: 'Test Parent',
      phoneNumber: '1234567890',
    );
  }

  group('Child Age Calculation (Relative to DateTime.now())', () {
    test('newborn (0 months)', () {
      final child = createChild(DateTime.now());
      expect(child.ageInMonths, 0);
    });

    test('one day before 2 months', () {
      final child = createChild(oneDayBeforeExact(2));
      expect(child.ageInMonths, 1);
    });

    test('exactly 2 months', () {
      final child = createChild(exactMonthsAgo(2));
      expect(child.ageInMonths, 2);
    });

    test('one day after 2 months', () {
      final child = createChild(oneDayAfterExact(2));
      expect(child.ageInMonths, 2);
    });

    test('exactly 60 months', () {
      final child = createChild(exactMonthsAgo(60));
      expect(child.ageInMonths, 60);
    });

    test('one day after 60 months', () {
      final child = createChild(oneDayAfterExact(60));
      expect(child.ageInMonths, 60);
    });

    test('one day before 61 months', () {
      // 60 months and some days
      final child = createChild(oneDayBeforeExact(61));
      expect(child.ageInMonths, 60);
    });

    test('exactly 61 months (out of bounds)', () {
      final child = createChild(exactMonthsAgo(61));
      expect(child.ageInMonths, 61);
    });
  });

  group('AgeGroup Mapping Boundaries', () {
    void verifyMapping(int months, AgeGroup expectedGroup) {
      final child = createChild(exactMonthsAgo(months));
      expect(
        child.ageGroup, 
        expectedGroup,
        reason: 'Failed for age: $months months. Expected: ${expectedGroup.name}',
      );
    }

    test('AgeGroup boundaries check', () {
      // 2-3 months
      verifyMapping(2, AgeGroup.twoToThreeMonths);
      verifyMapping(3, AgeGroup.twoToThreeMonths);

      // 4-6 months
      verifyMapping(4, AgeGroup.fourToSixMonths);
      verifyMapping(6, AgeGroup.fourToSixMonths);

      // 7-9 months
      verifyMapping(7, AgeGroup.sevenToNineMonths);
      verifyMapping(9, AgeGroup.sevenToNineMonths);

      // 10-12 months
      verifyMapping(10, AgeGroup.tenToTwelveMonths);
      verifyMapping(12, AgeGroup.tenToTwelveMonths);

      // 13-18 months
      verifyMapping(13, AgeGroup.thirteenToEighteenMonths);
      verifyMapping(18, AgeGroup.thirteenToEighteenMonths);

      // 19-24 months
      verifyMapping(19, AgeGroup.nineteenToTwentyFourMonths);
      verifyMapping(24, AgeGroup.nineteenToTwentyFourMonths);

      // 25-36 months
      verifyMapping(25, AgeGroup.twoToThreeYears);
      verifyMapping(36, AgeGroup.twoToThreeYears);

      // 37-48 months
      verifyMapping(37, AgeGroup.threeToFourYears);
      verifyMapping(48, AgeGroup.threeToFourYears);

      // 49-60 months
      verifyMapping(49, AgeGroup.fourToFiveYears);
      verifyMapping(60, AgeGroup.fourToFiveYears);
    });

    test('AgeGroup full range coverage and boundary transitions', () {
      // We test previous month, boundary month, and next month for the 13-18 to 19-24 transition
      
      // month 12 is in 10-12
      final child12 = createChild(exactMonthsAgo(12));
      expect(child12.ageGroup, AgeGroup.tenToTwelveMonths);

      // month 13 is in 13-18
      final child13 = createChild(exactMonthsAgo(13));
      expect(child13.ageGroup, AgeGroup.thirteenToEighteenMonths);

      // month 18 is in 13-18
      final child18 = createChild(exactMonthsAgo(18));
      expect(child18.ageGroup, AgeGroup.thirteenToEighteenMonths);

      // month 19 is in 19-24
      final child19 = createChild(exactMonthsAgo(19));
      expect(child19.ageGroup, AgeGroup.nineteenToTwentyFourMonths);
    });
  });

  group('Screening Range (2-60 months)', () {
    test('below minimum supported age -> unsupported', () {
      final child1 = createChild(exactMonthsAgo(0)); // 0 months
      expect(child1.isWithinScreeningRange, false);
      expect(child1.ageGroup, null);

      final child2 = createChild(exactMonthsAgo(1)); // 1 month
      expect(child2.isWithinScreeningRange, false);
      expect(child2.ageGroup, null);
    });

    test('minimum supported age -> supported', () {
      final child = createChild(exactMonthsAgo(2)); // exactly 2 months
      expect(child.isWithinScreeningRange, true);
      expect(child.ageGroup, isNotNull);
    });

    test('maximum supported age -> supported', () {
      final child = createChild(exactMonthsAgo(60)); // exactly 60 months
      expect(child.isWithinScreeningRange, true);
      expect(child.ageGroup, isNotNull);
    });

    test('above maximum supported age -> unsupported', () {
      final child = createChild(exactMonthsAgo(61)); // 61 months
      expect(child.isWithinScreeningRange, false);
      expect(child.ageGroup, null);
    });
  });
}
