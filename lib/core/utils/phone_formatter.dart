import 'package:flutter/services.dart';

/// Formats a phone string into `+998 XX XXX XX XX` format with spaces
String formatUzPhone(String phone) {
  final clean = phone.trim();
  if (clean.isEmpty) return '';

  final digits = clean.replaceAll(RegExp(r'\D'), '');
  String pure = digits;
  if (pure.startsWith('998')) {
    pure = pure.substring(3);
  }

  if (pure.length >= 9) {
    final code = pure.substring(0, 2);
    final p1 = pure.substring(2, 5);
    final p2 = pure.substring(5, 7);
    final p3 = pure.substring(7, 9);
    return '+998 $code $p1 $p2 $p3';
  } else if (pure.isNotEmpty) {
    final buffer = StringBuffer('+998 ');
    buffer.write(pure.substring(0, pure.length.clamp(0, 2)));
    if (pure.length > 2) {
      buffer.write(' ');
      buffer.write(pure.substring(2, pure.length.clamp(2, 5)));
    }
    if (pure.length > 5) {
      buffer.write(' ');
      buffer.write(pure.substring(5, pure.length.clamp(5, 7)));
    }
    if (pure.length > 7) {
      buffer.write(' ');
      buffer.write(pure.substring(7, pure.length.clamp(7, 9)));
    }
    return buffer.toString();
  }

  return phone;
}

/// Text input formatter for Uzbek phone numbers (`+998 XX XXX XX XX`)
class UzPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) {
      return newValue;
    }

    String digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('998')) {
      digits = digits.substring(3);
    }
    if (digits.length > 9) {
      digits = digits.substring(0, 9);
    }

    final formatted = formatUzPhone(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
