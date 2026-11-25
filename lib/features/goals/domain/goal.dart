enum GoalTracking { checklist, counter, manual }

enum GoalIcon { target, book, fitness, project, language }

enum GoalColor { primary, secondary, tertiary }

class GoalMilestone {
  GoalMilestone({
    this.id,
    required this.title,
    DateTime? createdAt,
    this.completedAt,
    this.fromDaily = false,
    this.activityId,
    this.createActivity = false,
  }) : createdAt = createdAt ?? DateTime.now();

  final int? id;
  final String title;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool fromDaily;
  final int? activityId;
  final bool createActivity;
  bool get linked => activityId != null || createActivity;

  bool get complete => completedAt != null || fromDaily;
  GoalMilestone rename(String value) => GoalMilestone(
    id: id,
    title: value,
    createdAt: createdAt,
    completedAt: completedAt,
    fromDaily: fromDaily,
    activityId: activityId,
    createActivity: createActivity,
  );
  GoalMilestone toggle() => GoalMilestone(
    id: id,
    title: title,
    createdAt: createdAt,
    completedAt: complete ? null : DateTime.now(),
    fromDaily: fromDaily,
    activityId: activityId,
    createActivity: createActivity,
  );
}

class Goal {
  Goal({
    this.id,
    required this.title,
    this.description = '',
    this.icon = GoalIcon.target,
    this.color = GoalColor.primary,
    this.tracking = GoalTracking.checklist,
    required this.startDate,
    this.targetDate,
    this.targetValue = 1,
    this.manualProgress = 0,
    this.dailyCredits = 0,
    List<GoalMilestone> milestones = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.completionDate,
  }) : milestones = List.unmodifiable(milestones),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  final int? id;
  final String title, description;
  final GoalIcon icon;
  final GoalColor color;
  final GoalTracking tracking;
  final DateTime startDate, createdAt, updatedAt;
  final DateTime? targetDate, completionDate;
  DateTime? get completedAt => completed ? completionDate : null;
  final double targetValue;
  final int manualProgress;
  final int dailyCredits;
  final List<GoalMilestone> milestones;

  static DateTime day(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  int get completedSteps => milestones.where((step) => step.complete).length;
  double get totalValue => dailyCredits.toDouble();

  double get progress => switch (tracking) {
    GoalTracking.checklist =>
      milestones.isEmpty ? 0.0 : completedSteps / milestones.length,
    GoalTracking.counter =>
      targetValue <= 0 || !targetValue.isFinite
          ? 0.0
          : (totalValue / targetValue).clamp(0.0, 1.0),
    GoalTracking.manual => (manualProgress + dailyCredits).clamp(0, 100) / 100,
  };

  int get percentage => completed ? 100 : (progress * 100).round().clamp(0, 99);
  bool get completed => progress >= 1;
  bool overdue(DateTime today) =>
      !completed && targetDate != null && day(targetDate!).isBefore(day(today));

  bool get hasTrackingData => switch (tracking) {
    GoalTracking.checklist => milestones.isNotEmpty,
    GoalTracking.counter => totalValue > 0,
    GoalTracking.manual => manualProgress > 0 || dailyCredits > 0,
  };

  bool get valid =>
      title.trim().isNotEmpty &&
      (targetDate == null || !day(targetDate!).isBefore(day(startDate))) &&
      (tracking != GoalTracking.counter ||
          (targetValue.isFinite &&
              targetValue >= 1 &&
              targetValue == targetValue.truncateToDouble())) &&
      (tracking != GoalTracking.manual ||
          (manualProgress >= 0 && manualProgress <= 100)) &&
      (tracking != GoalTracking.checklist ||
          milestones.every((step) => step.title.trim().isNotEmpty));

  Goal withProgress({int? percent, List<GoalMilestone>? steps}) => Goal(
    id: id,
    title: title,
    description: description,
    icon: icon,
    color: color,
    tracking: tracking,
    startDate: startDate,
    targetDate: targetDate,
    targetValue: targetValue,
    manualProgress: percent ?? manualProgress,
    dailyCredits: dailyCredits,
    milestones: steps ?? milestones,
    createdAt: createdAt,
    updatedAt: updatedAt,
    completionDate: completedAt,
  );
}
