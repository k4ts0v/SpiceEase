class FlowmodoroModel {
  final String id;
  final String taskId;
  final int focusMinutes;
  final int breakMinutes;
  final int pomoCount;
  final bool isRunning;
  final bool isCompleted; // New field to track completion
  final DateTime createdAt;

  FlowmodoroModel({
    required this.id,
    required this.taskId,
    this.focusMinutes = 25,
    this.breakMinutes = 5,
    this.pomoCount = 4,
    this.isRunning = false,
    this.isCompleted = false,
    DateTime? createdAt, // Make it optional but set default in constructor
  }) : this.createdAt = createdAt ?? DateTime.now();

  FlowmodoroModel copyWith({
    String? id,
    String? taskId,
    int? focusMinutes,
    int? breakMinutes,
    int? pomoCount,
    bool? isRunning,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return FlowmodoroModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      pomoCount: pomoCount ?? this.pomoCount,
      isRunning: isRunning ?? this.isRunning,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory FlowmodoroModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return FlowmodoroModel(
      id: id ?? map['id'],
      taskId: map['task_id'],
      focusMinutes: map['focus_minutes'] ?? 25,
      breakMinutes: map['break_minutes'] ?? 5,
      pomoCount: map['pomo_count'] ?? 4,
      isRunning: map['is_running'] ?? false,
      isCompleted: map['is_completed'] ?? false,
      createdAt: map['created_at'] != null
          ? (map['created_at'] is DateTime
              ? map['created_at']
              : DateTime.parse(map['created_at']))
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'focus_minutes': focusMinutes,
      'break_minutes': breakMinutes,
      'pomo_count': pomoCount,
      'is_running': isRunning,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
