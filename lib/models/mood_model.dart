import 'package:flutter/material.dart';

/// Model for a single mood log/entry.
class MoodModel {
  final String id;
  final int rating; // 1 to 5
  final String label; // Rad, Good, Meh, Bad, Awful
  final String note;
  final DateTime timestamp;
  final String emoji;

  MoodModel({
    required this.id,
    required this.rating,
    required this.label,
    required this.note,
    required this.timestamp,
    required this.emoji,
  });

  /// Factory constructor to create from Firestore map (if needed later)
  factory MoodModel.fromMap(Map<String, dynamic> map, String docId) {
    return MoodModel(
      id: docId,
      rating: map['rating'] ?? 3,
      label: map['label'] ?? 'Meh',
      note: map['note'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      emoji: map['emoji'] ?? '😐',
    );
  }

  /// Converts model to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      'label': label,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
      'emoji': emoji,
    };
  }

  /// Gets the theme color associated with this mood
  Color get color {
    switch (rating) {
      case 5:
        return const Color(0xFFFFB800); // Neon Yellow/Amber (Rad)
      case 4:
        return const Color(0xFF00E5FF); // Bright Cyan (Good)
      case 3:
        return const Color(0xFF9E9E9E); // Cool Grey (Meh)
      case 2:
        return const Color(0xFFFF5252); // Soft Red (Bad)
      case 1:
        return const Color(0xFF7C4DFF); // Deep Purple (Awful)
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}