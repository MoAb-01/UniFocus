class AppConstants {
  AppConstants._();

  static const String appName = 'UniFocus';
  static const String appTagline = 'Study smarter. Stay organized.';
  static const String developerCredit = 'Developed by ';
  static const String appVersion = '1.0.1';

  // Academic Years
  static const List<String> academicYears = [
    '1st Year (Prep / Freshman)',
    '2nd Year (Sophomore)',
    '3rd Year (Junior)',
    '4th Year (Senior)',
    'Graduate (Master / PhD)',
  ];

  // Academic Terms
  static const List<String> academicTerms = [
    'Fall',
    'Spring',
    'Summer',
  ];

  // Turkish Letter Grades and 4.00 Grade Points
  static const Map<String, double> gradeScale = {
    'AA': 4.00,
    'BA': 3.50,
    'BB': 3.00,
    'CB': 2.50,
    'CC': 2.00,
    'DC': 1.50,
    'DD': 1.00,
    'FD': 0.50,
    'FF': 0.00,
  };

  // Grade descriptions
  static const Map<String, String> gradeDescriptions = {
    'AA': 'Excellent (Mükemmel)',
    'BA': 'Very Good (Çok İyi)',
    'BB': 'Good (İyi)',
    'CB': 'Above Average (Orta Üstü)',
    'CC': 'Satisfactory (Geçer)',
    'DC': 'Conditional Pass (Koşullu Geçer)',
    'DD': 'Conditional Pass (Koşullu Geçer)',
    'FD': 'Fail (Başarısız)',
    'FF': 'Fail (Devamsız/Başarısız)',
  };

  // Passing grades (CC and above are fully passed, DC/DD conditional)
  static bool isPassingGrade(String grade) {
    return grade != 'FD' && grade != 'FF';
  }

  // Event Categories
  static const List<String> eventTypes = [
    'Class',
    'Exam',
    'Quiz',
    'Assignment',
    'Project',
    'Presentation',
    'Study Session',
    'Personal Reminder',
  ];

  // Task Priorities
  static const List<String> priorities = [
    'Low',
    'Medium',
    'High',
  ];

  // Document Categories
  static const List<String> documentCategories = [
    'Lecture Notes',
    'Homework',
    'Exam Review',
    'Handwritten',
    'Book Chapter',
  ];
}
