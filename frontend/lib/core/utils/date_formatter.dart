import 'package:intl/intl.dart';

class DateFormatter {
  static String timeAgo(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inSeconds < 60)  return 'Az önce';
      if (diff.inMinutes < 60)  return '${diff.inMinutes} dk önce';
      if (diff.inHours < 24)    return '${diff.inHours} saat önce';
      if (diff.inDays < 7)      return '${diff.inDays} gün önce';
      if (diff.inDays < 30)     return '${(diff.inDays / 7).floor()} hafta önce';
      return DateFormat('d MMM yyyy', 'tr').format(date);
    } catch (_) {
      return isoString;
    }
  }

  static String formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('d MMMM yyyy', 'tr').format(date);
    } catch (_) {
      return isoString;
    }
  }

  static String formatDateShort(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('d MMM', 'tr').format(date);
    } catch (_) {
      return isoString;
    }
  }

  static bool isUpcoming(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return date.isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }
}
