import 'package:flutter/material.dart';

class AvatarColors {
  static const List<Color> colors = [
    Color(0xFF4A90E2),
    Color(0xFF0A8F63),
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFA500),
    Color(0xFF2E7C8F),
    Color(0xFFFF1493),
    Color(0xFF00CED1),
    Color(0xFFDC143C),
    Color(0xFF07563D),
  ];

  static Color getColor(int hash) {
    final index = hash.abs() % colors.length;
    return colors[index];
  }

  static const Color textColor = Colors.white;
}
