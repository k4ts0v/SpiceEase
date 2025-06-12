import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum NotificationPriority { low, medium, high, critical }

enum NotificationType {
  task,
  habit,
  medication,
  appointment,
  symptom,
  energy,
  system
}

class AppNotification extends Equatable {
  final String id;
  final String title;
  final String body;
  final NotificationPriority priority;
  final NotificationType type;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final bool isRead;
  final bool isPersistent;
  final Map<String, dynamic>? actionData;
  final ContextRule? contextRule;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.priority,
    required this.type,
    required this.createdAt,
    this.scheduledFor,
    this.isRead = false,
    this.isPersistent = false,
    this.actionData,
    this.contextRule,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationPriority? priority,
    NotificationType? type,
    DateTime? createdAt,
    DateTime? scheduledFor,
    bool? isRead,
    bool? isPersistent,
    Map<String, dynamic>? actionData,
    ContextRule? contextRule,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      priority: priority ?? this.priority,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      isRead: isRead ?? this.isRead,
      isPersistent: isPersistent ?? this.isPersistent,
      actionData: actionData ?? this.actionData,
      contextRule: contextRule ?? this.contextRule,
    );
  }

  // Convert AppNotification to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'priority': priority.toString().split('.').last,
      'type': type.toString().split('.').last,
      'created_at': Timestamp.fromDate(createdAt),
      'scheduled_for': scheduledFor != null ? Timestamp.fromDate(scheduledFor!) : null,
      'is_read': isRead,
      'is_persistent': isPersistent,
      'action_data': actionData,
      'context_rule': contextRule?.toMap(),
    };
  }

  // Create AppNotification from Firestore Map
  static AppNotification fromMap(Map<String, dynamic> map, String documentId) {
    return AppNotification(
      id: documentId,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      priority: _priorityFromString(map['priority'] ?? 'medium'),
      type: _typeFromString(map['type'] ?? 'system'),
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      scheduledFor: (map['scheduled_for'] as Timestamp?)?.toDate(),
      isRead: map['is_read'] ?? false,
      isPersistent: map['is_persistent'] ?? false,
      actionData: map['action_data'] != null
          ? Map<String, dynamic>.from(map['action_data'])
          : null,
      contextRule: map['context_rule'] != null
          ? ContextRule.fromMap(Map<String, dynamic>.from(map['context_rule']))
          : null,
    );
  }

  // Helper method to convert string to NotificationPriority enum
  static NotificationPriority _priorityFromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return NotificationPriority.low;
      case 'medium':
        return NotificationPriority.medium;
      case 'high':
        return NotificationPriority.high;
      case 'critical':
        return NotificationPriority.critical;
      default:
        return NotificationPriority.medium;
    }
  }

  // Helper method to convert string to NotificationType enum
  static NotificationType _typeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'task':
        return NotificationType.task;
      case 'habit':
        return NotificationType.habit;
      case 'medication':
        return NotificationType.medication;
      case 'appointment':
        return NotificationType.appointment;
      case 'symptom':
        return NotificationType.symptom;
      case 'energy':
        return NotificationType.energy;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.system;
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        priority,
        type,
        createdAt,
        scheduledFor,
        isRead,
        isPersistent,
        actionData,
        contextRule
      ];
}

class SymptomImpact {
  final int maxSeverity;
  final int totalSymptoms;
  final bool shouldBlockNotifications;
  final double? averageSeverity;

  const SymptomImpact({
    required this.maxSeverity,
    required this.totalSymptoms,
    required this.shouldBlockNotifications,
    this.averageSeverity,
  });
}

class ContextRule {
  final int? minEnergyLevel; // Only show if energy is above this
  final int? maxSymptomSeverity; // Only show if symptoms are below this (capped at 10)
  final TimeOfDay? preferredTimeStart; // Preferred time window to show
  final TimeOfDay? preferredTimeEnd;
  final bool skipWhenFocused; // Skip if user is in focus/flow mode
  final bool onlyWhenIdle; // Only show when user isn't active in app

  const ContextRule({
    this.minEnergyLevel,
    this.maxSymptomSeverity,
    this.preferredTimeStart,
    this.preferredTimeEnd,
    this.skipWhenFocused = false,
    this.onlyWhenIdle = false,
  });

  bool shouldShowForContext({
    required int currentEnergy,
    required int currentSymptomLevel, // Now capped at 10
    required TimeOfDay currentTime,
    required bool isInFocusMode,
    required bool isAppActive,
  }) {
    // Check energy threshold
    if (minEnergyLevel != null && currentEnergy < minEnergyLevel!) {
      return false;
    }

    // Check symptom threshold (capped at 10)
    final cappedSymptomLevel = currentSymptomLevel.clamp(0, 10);
    if (maxSymptomSeverity != null &&
        cappedSymptomLevel > maxSymptomSeverity!) {
      return false;
    }

    // Check time window
    if (preferredTimeStart != null && preferredTimeEnd != null) {
      final now = (currentTime.hour * 60) + currentTime.minute;
      final start =
          (preferredTimeStart!.hour * 60) + preferredTimeStart!.minute;
      final end = (preferredTimeEnd!.hour * 60) + preferredTimeEnd!.minute;

      if (!(now >= start && now <= end)) {
        return false;
      }
    }

    // Check focus mode
    if (skipWhenFocused && isInFocusMode) {
      return false;
    }

    // Check app activity
    if (onlyWhenIdle && isAppActive) {
      return false;
    }

    return true;
  }

  // Convert ContextRule to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'min_energy_level': minEnergyLevel,
      'max_symptom_severity': maxSymptomSeverity,
      'preferred_time_start': preferredTimeStart != null
          ? {'hour': preferredTimeStart!.hour, 'minute': preferredTimeStart!.minute}
          : null,
      'preferred_time_end': preferredTimeEnd != null
          ? {'hour': preferredTimeEnd!.hour, 'minute': preferredTimeEnd!.minute}
          : null,
      'skip_when_focused': skipWhenFocused,
      'only_when_idle': onlyWhenIdle,
    };
  }

  // Create ContextRule from Firestore Map
  static ContextRule fromMap(Map<String, dynamic> map) {
    TimeOfDay? parseTimeOfDay(Map<String, dynamic>? timeMap) {
      if (timeMap == null) return null;
      return TimeOfDay(
        hour: timeMap['hour'] ?? 0,
        minute: timeMap['minute'] ?? 0,
      );
    }

    return ContextRule(
      minEnergyLevel: map['min_energy_level'],
      maxSymptomSeverity: map['max_symptom_severity'],
      preferredTimeStart: parseTimeOfDay(
        map['preferred_time_start'] != null
            ? Map<String, dynamic>.from(map['preferred_time_start'])
            : null
      ),
      preferredTimeEnd: parseTimeOfDay(
        map['preferred_time_end'] != null
            ? Map<String, dynamic>.from(map['preferred_time_end'])
            : null
      ),
      skipWhenFocused: map['skip_when_focused'] ?? false,
      onlyWhenIdle: map['only_when_idle'] ?? false,
    );
  }

  ContextRule copyWith({
    int? minEnergyLevel,
    int? maxSymptomSeverity,
    TimeOfDay? preferredTimeStart,
    TimeOfDay? preferredTimeEnd,
    bool? skipWhenFocused,
    bool? onlyWhenIdle,
  }) {
    return ContextRule(
      minEnergyLevel: minEnergyLevel ?? this.minEnergyLevel,
      maxSymptomSeverity: maxSymptomSeverity ?? this.maxSymptomSeverity,
      preferredTimeStart: preferredTimeStart ?? this.preferredTimeStart,
      preferredTimeEnd: preferredTimeEnd ?? this.preferredTimeEnd,
      skipWhenFocused: skipWhenFocused ?? this.skipWhenFocused,
      onlyWhenIdle: onlyWhenIdle ?? this.onlyWhenIdle,
    );
  }
}