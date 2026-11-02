import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../domain/daily_activity.dart';
import '../daily_activity_icons.dart';

class DailyActivityCard extends StatelessWidget {
  const DailyActivityCard({
    required this.activity,
    required this.completed,
    required this.onTap,
    required this.onCompleted,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final DailyActivity activity;
  final bool completed;
  final VoidCallback onTap;
  final VoidCallback onCompleted;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final time = activity.schedule.hasSpecificTime
        ? MaterialLocalizations.of(context).formatTimeOfDay(
            TimeOfDay(
              hour: activity.schedule.hour!,
              minute: activity.schedule.minute!,
            ),
          )
        : strings.daily('anytime');

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(
                  DailyActivityIcons.iconFor(activity.iconKey),
                  color: colors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        decoration: completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 18,
                      child: Row(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (activity.schedule.hasSpecificTime) ...[
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: colors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 5),
                              ],
                              Flexible(
                                child: Text(
                                  time,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (activity.schedule.hasSpecificTime) ...[
                            const SizedBox(width: 8),
                            Flexible(
                              child: DailyReminderIndicator(
                                enabled: activity.notificationsEnabled,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: strings.daily('edit'),
                icon: const Icon(Icons.edit_outlined, size: 20),
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  backgroundColor: colors.surfaceContainerHighest.withValues(
                    alpha: 0.45,
                  ),
                ),
                onPressed: onEdit,
              ),
              Checkbox(
                value: completed,
                onChanged: (_) => onCompleted(),
                shape: const CircleBorder(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DailyReminderIndicator extends StatelessWidget {
  const DailyReminderIndicator({required this.enabled, super.key});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          enabled
              ? Icons.notifications_active_outlined
              : Icons.notifications_off_outlined,
          size: 14,
          color: enabled ? colors.primary : colors.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            enabled
                ? strings.daily('notificationEnabled')
                : strings.daily('notificationDisabled'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: enabled ? colors.primary : colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
