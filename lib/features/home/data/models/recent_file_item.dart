import 'package:flutter/material.dart';

/// Model representing a recently accessed file.
class RecentFileItem {
  const RecentFileItem({
    required this.name,
    required this.type,
    required this.date,
    required this.icon,
    required this.color,
    this.size,
    this.filePath,
  });

  /// Creates an item from a JSON map.
  factory RecentFileItem.fromJson(Map<String, dynamic> json) {
    return RecentFileItem(
      name: json['name'] as String,
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
      icon: IconData(
        // ignore: non_const_argument_for_const_parameter
        json['iconCodePoint'] as int,
        fontFamily: 'MaterialIcons',
      ),
      color: Color(json['colorValue'] as int),
      size: json['size'] as String?,
      filePath: json['filePath'] as String?,
    );
  }

  /// File name.
  final String name;

  /// File type (e.g., 'PDF', 'Image', 'Audio').
  final String type;

  /// Date the file was last accessed.
  final DateTime date;

  /// File icon.
  final IconData icon;

  /// Accent color for the file.
  final Color color;

  /// Optional file size string.
  final String? size;

  /// Optional file path.
  final String? filePath;

  /// Creates a copy with updated fields.
  RecentFileItem copyWith({
    String? name,
    String? type,
    DateTime? date,
    IconData? icon,
    Color? color,
    String? size,
    String? filePath,
  }) {
    return RecentFileItem(
      name: name ?? this.name,
      type: type ?? this.type,
      date: date ?? this.date,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      size: size ?? this.size,
      filePath: filePath ?? this.filePath,
    );
  }

  /// Converts the item to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'type': type,
      'date': date.toIso8601String(),
      'iconCodePoint': icon.codePoint,
      'colorValue': color.toARGB32(),
      'size': size,
      'filePath': filePath,
    };
  }
}
