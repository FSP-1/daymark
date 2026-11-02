import 'package:flutter/material.dart';

class DailyActivityIcons {
  static const defaultKey = 'repeat';

  static const keys = [
    'repeat',
    'fitness',
    'book',
    'walk',
    'study',
    'home',
    'water',
    'music',
    'work',
    'food',
    'sleep',
  ];

  static IconData iconFor(String key) {
    return switch (key) {
      'fitness' => Icons.fitness_center_outlined,
      'book' => Icons.menu_book_outlined,
      'walk' => Icons.directions_walk_outlined,
      'study' => Icons.school_outlined,
      'home' => Icons.home_outlined,
      'water' => Icons.water_drop_outlined,
      'music' => Icons.music_note_outlined,
      'work' => Icons.work_outline,
      'food' => Icons.restaurant_outlined,
      'sleep' => Icons.bed_outlined,
      _ => Icons.repeat,
    };
  }
}
