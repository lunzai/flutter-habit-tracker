enum GoalRepeatInterval { daily, weekly, monthly }
enum ProgressType { incremental, decremental }

class Habit {
  final int? id;
  final String title;
  final String? description;
  final String goalAction;
  final double goalCount;
  final String goalUnit;
  final int goalRepeat;
  final String goalRepeatInterval;
  final bool goalHasExpectedEndDate;
  final DateTime? goalExpectedEndDate;
  final String progressType;
  final double progressStep;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Habit({
    this.id,
    required this.title,
    this.description,
    this.goalAction = 'do',
    this.goalCount = 1,
    this.goalUnit = 'times',
    this.goalRepeat = 1,
    this.goalRepeatInterval = 'day',
    this.goalHasExpectedEndDate = false,
    this.goalExpectedEndDate,
    this.progressType = 'increment',
    this.progressStep = 1,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'goal_action': goalAction,
      'goal_count': goalCount,
      'goal_unit': goalUnit,
      'goal_repeat': goalRepeat,
      'goal_repeat_interval': goalRepeatInterval,
      'goal_has_expected_end_date': goalHasExpectedEndDate ? 1 : 0,
      'goal_expected_end_date': goalExpectedEndDate?.toIso8601String(),
      'progress_type': progressType,
      'progress_step': progressStep,
      'is_archived': isArchived ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as int?,
      title: map['title'],
      description: map['description'],
      goalAction: map['goal_action'],
      goalCount: map['goal_count'],
      goalUnit: map['goal_unit'],
      goalRepeat: map['goal_repeat'],
      goalRepeatInterval: map['goal_repeat_interval'],
      goalHasExpectedEndDate: map['goal_has_expected_end_date'] == 1,
      goalExpectedEndDate: map['goal_expected_end_date'] != null 
          ? DateTime.parse(map['goal_expected_end_date'])
          : null,
      progressType: map['progress_type'],
      progressStep: map['progress_step'],
      isArchived: map['is_archived'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
} 