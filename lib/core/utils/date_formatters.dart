import 'package:intl/intl.dart';

class DateFormatters {
  DateFormatters._();

  static final DateFormat fullDate = DateFormat('MMMM d, yyyy');
  static final DateFormat shortDate = DateFormat('MMM d');
  static final DateFormat time24 = DateFormat('HH:mm');
  static final DateFormat dayMonth = DateFormat('EEEE, d MMMM');
  static final DateFormat semesterFormat = DateFormat('y');

  static String formatRelativeDue(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.isNegative) {
      final days = (-difference.inDays);
      if (days == 0) return 'Overdue today';
      return '$days ${days == 1 ? 'day' : 'days'} overdue';
    }

    if (difference.inDays == 0) {
      if (difference.inHours > 0) {
        return '${difference.inHours}h remaining';
      }
      return 'Due today';
    }

    if (difference.inDays == 1) {
      return 'Due tomorrow';
    }

    return '${difference.inDays} days remaining';
  }

  static String formatDurationMinutes(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '${hours}h';
    }
    return '${hours}h ${mins}m';
  }
}
