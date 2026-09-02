import 'package:intl/intl.dart';

/// Formatting utilities for dates, numbers, and file sizes.
abstract final class Formatters {
  /// Formats a date as 'MMM d, yyyy' (e.g., 'Aug 4, 2026').
  static String date(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  /// Formats a date with time as 'MMM d, yyyy • h:mm a'.
  static String dateTime(DateTime date) {
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }

  /// Formats a time as 'h:mm a' (e.g., '2:30 PM').
  static String time(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  /// Formats a relative time string (e.g., 'Just now', '5m ago', '2h ago').
  static String relativeTime(DateTime date) {
    final Duration difference = DateTime.now().difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    }
    return '${(difference.inDays / 365).floor()}y ago';
  }

  /// Formats a file size in bytes to a human-readable string.
  static String fileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Formats a number with thousands separators (e.g., '1,234,567').
  static String number(num value) {
    return NumberFormat('#,##0').format(value);
  }

  /// Formats a decimal number with up to 2 decimal places.
  static String decimal(num value, {int decimals = 2}) {
    return NumberFormat('0.${'0' * decimals}').format(value);
  }

  /// Formats a percentage (e.g., '45.5%').
  static String percent(num value, {int decimals = 1}) {
    return '${decimal(value, decimals: decimals)}%';
  }

  /// Formats a duration in seconds as 'm:ss' (e.g., '3:45').
  static String duration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Formats a word count as a readable string.
  static String wordCount(int count) {
    if (count == 1) {
      return '1 word';
    }
    return '$count words';
  }

  /// Formats a character count as a readable string.
  static String charCount(int count) {
    if (count == 1) {
      return '1 character';
    }
    return '$count characters';
  }

  /// Truncates a string to a maximum length with an ellipsis.
  static String truncate(String text, {int maxLength = 50}) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// Capitalizes the first letter of each word.
  static String titleCase(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text.split(' ').map((String word) {
      if (word.isEmpty) {
        return word;
      }
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}
