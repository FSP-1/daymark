import 'package:material_ui/material_ui.dart';

import '../domain/goal.dart';

IconData goalIcon(GoalIcon icon) => switch (icon) {
  GoalIcon.target => Icons.track_changes,
  GoalIcon.book => Icons.menu_book_outlined,
  GoalIcon.fitness => Icons.fitness_center,
  GoalIcon.project => Icons.rocket_launch_outlined,
  GoalIcon.language => Icons.translate,
};

Color goalColor(BuildContext context, GoalColor color) {
  final colors = Theme.of(context).colorScheme;
  return switch (color) {
    GoalColor.primary => colors.primary,
    GoalColor.secondary => colors.secondary,
    GoalColor.tertiary => colors.tertiary,
  };
}
