import 'package:flutter_test/flutter_test.dart';
import 'package:unifocus/core/constants/app_constants.dart';
import 'package:unifocus/core/utils/grade_calculator.dart';
import 'package:unifocus/core/models/course.dart';

void main() {
  test('AppConstants verifies basic configuration', () {
    expect(AppConstants.appName, 'UniFocus');
    expect(AppConstants.developerCredit, 'Developed by Mohamed Abdou');
  });

  test('GradeCalculator calculates semester GPA accurately', () {
    final courses = [
      const Course(
        id: 'c1',
        code: 'CENG401',
        name: 'Thesis',
        instructor: 'Dr. Yılmaz',
        credit: 3,
        akts: 6,
        programId: 'main',
        semesterId: 's1',
        letterGrade: 'AA', // 4.00 * 6 = 24
      ),
      const Course(
        id: 'c2',
        code: 'CENG305',
        name: 'Networks',
        instructor: 'Dr. Demir',
        credit: 3,
        akts: 4,
        programId: 'main',
        semesterId: 's1',
        letterGrade: 'BA', // 3.50 * 4 = 14
      ),
    ];

    // (24 + 14) / 10 = 3.80
    final gpa = GradeCalculator.calculateSemesterGpa(courses);
    expect(gpa, 3.80);
  });
}
