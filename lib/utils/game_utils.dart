import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scavhuntapp/utils/theme_data.dart';

Color getColor(String color) {
  switch (color) {
    case 'red':
      return Colors.red;
    case 'blue':
      return Colors.blue;
    case 'green':
      return Colors.green;
    case 'yellow':
      return Colors.yellow;
    case 'purple':
      return Colors.purple;
    case 'orange':
      return Colors.orange;
    case 'pink':
      return Colors.pink;
    case 'cyan':
      return Colors.cyan;
    case 'teal':
      return Colors.teal;
    case 'indigo':
      return Colors.indigo;
    case 'amber':
      return Colors.amber;
    case 'lime':
      return Colors.lime;
    case 'brown':
      return Colors.brown;
    case 'grey':
      return Colors.grey;
    case 'deepOrange':
      return Colors.deepOrange;
    case 'deepPurple':
      return Colors.deepPurple;
    case 'lightBlue':
      return Colors.lightBlue;
    case 'lightGreen':
      return Colors.lightGreen;
    case 'blueGrey':
      return Colors.blueGrey;
    default:
      return Colors.blue;
  }
}

Widget buildGlassCard({required String title, required Widget child}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty)
                Text(
                  title,
                  style: baseTextStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              if (title.isNotEmpty) const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    ),
  );
}
