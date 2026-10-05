import '../constants/app_constants.dart';
import '../models/course.dart';
import '../models/semester.dart';

class GradeCalculator {
  GradeCalculator._();

  /// Calculates the semester GPA based on AKTS and letter grades.
  static double calculateSemesterGpa(List<Course> courses) {
    double totalPoints = 0.0;
    int totalGradedAkts = 0;

    for (final course in courses) {
      if (course.letterGrade != null &&
          AppConstants.gradeScale.containsKey(course.letterGrade)) {
        final points = AppConstants.gradeScale[course.letterGrade]!;
        totalPoints += points * course.akts;
        totalGradedAkts += course.akts;
      }
    }

    if (totalGradedAkts == 0) return 0.0;
    return double.parse((totalPoints / totalGradedAkts).toStringAsFixed(2));
  }

  /// Calculates cumulative GANO across all semesters for a given program.
  static double calculateCumulativeGano(List<Semester> semesters) {
    double totalWeightedPoints = 0.0;
    int totalCompletedAkts = 0;

    for (final semester in semesters) {
      for (final course in semester.courses) {
        if (course.letterGrade != null &&
            AppConstants.gradeScale.containsKey(course.letterGrade)) {
          final points = AppConstants.gradeScale[course.letterGrade]!;
          totalWeightedPoints += points * course.akts;
          totalCompletedAkts += course.akts;
        }
      }
    }

    if (totalCompletedAkts == 0) return 0.0;
    return double.parse((totalWeightedPoints / totalCompletedAkts).toStringAsFixed(2));
  }

  /// Calculates total completed AKTS.
  static int calculateTotalCompletedAkts(List<Semester> semesters) {
    int akts = 0;
    for (final semester in semesters) {
      for (final course in semester.courses) {
        if (course.isCompleted || (course.letterGrade != null && AppConstants.isPassingGrade(course.letterGrade!))) {
          akts += course.akts;
        }
      }
    }
    return akts;
  }

  /// Calculates required GPA on remaining credits to reach a target GANO.
  /// Returns null if target is mathematically impossible (> 4.00).
  static double? calculateRequiredGpaForTarget({
    required double currentGano,
    required int completedAkts,
    required int remainingAkts,
    required double targetGano,
  }) {
    if (remainingAkts <= 0) return null;
    final totalAkts = completedAkts + remainingAkts;
    final targetTotalPoints = targetGano * totalAkts;
    final currentPoints = currentGano * completedAkts;
    final neededPoints = targetTotalPoints - currentPoints;
    final requiredGpa = neededPoints / remainingAkts;

    if (requiredGpa > 4.00 || requiredGpa < 0.0) {
      return null;
    }
    return double.parse(requiredGpa.toStringAsFixed(2));
  }
}
