class Progress {
  final int? id;
  final int habitId;
  final double value;
  final String? note;
  final DateTime createdAt;

  Progress({
    this.id,
    required this.habitId,
    required this.value,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'value': value,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Progress.fromMap(Map<String, dynamic> map) {
    return Progress(
      id: map['id'] as int?,
      habitId: map['habit_id'] as int,
      value: map['value'] as double,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
} 