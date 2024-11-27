import 'package:cloud_firestore/cloud_firestore.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hari ini';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else {
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  static String formatTime(DateTime date) {
    String addLeadingZero(int value) {
      return value.toString().padLeft(2, '0');
    }

    return '${addLeadingZero(date.hour)}:${addLeadingZero(date.minute)}';
  }

  static String formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${formatDate(date)} ${formatTime(date)}';
  }

  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${formatTime(date)}';
  }
}
