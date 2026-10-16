import 'package:intl/intl.dart';

class DateTimeFormatter {
  DateTimeFormatter._();

  static String formatTime(dynamic iso) {
    final d = _parse(iso);
    if (d == null) return '';
    return DateFormat('h:mm a').format(d);
  }

  static String formatDate(dynamic iso) {
    final d = _parse(iso);
    if (d == null) return '';
    return DateFormat.yMMMd().format(d);
  }

  static String formatDateTime(dynamic iso) {
    final d = _parse(iso);
    if (d == null) return '';
    return '${DateFormat.yMMMd().format(d)} ${DateFormat('h:mm a').format(d)}';
  }

  static String formatFull(dynamic iso) => formatDateTime(iso);

  static String formatChatDate(dynamic iso) {
    final d = _parse(iso);
    if (d == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat.yMMMd().format(d);
  }

  static String formatExactTimeOrDate(dynamic iso) {
    final d = _parse(iso);
    if (d == null) return '';
    final now = DateTime.now();
    final isToday = d.year == now.year && d.month == now.month && d.day == now.day;
    if (isToday) {
      return DateFormat('h:mm a').format(d);
    }
    return '${DateFormat.MMMd().format(d)} ${DateFormat('h:mm a').format(d)}';
  }

  static String timeAgo(dynamic iso) {
    final d = _parse(iso);
    if (d == null) return '';
    final diff = DateTime.now().difference(d);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  static DateTime? _parse(dynamic input) {
    if (input == null) return null;
    DateTime? dt;
    if (input is DateTime) {
      dt = input;
    } else if (input is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(input);
    } else if (input is String) {
      dt = DateTime.tryParse(input);
    }
    return dt?.toLocal();
  }
}
