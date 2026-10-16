class StringUtils {
  StringUtils._();

  static String initials(String? first, [String? last]) {
    final f = (first != null && first.isNotEmpty) ? first[0] : '?';
    final l = (last != null && last.isNotEmpty) ? last[0] : '';
    return '$f$l'.toUpperCase();
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    if (phone.length == 12 && phone.startsWith('91')) {
      return '+91 ${phone.substring(2, 7)} ${phone.substring(7)}';
    }
    if (phone.length == 10) {
      return '+91 ${phone.substring(0, 5)} ${phone.substring(5)}';
    }
    return phone;
  }
}
