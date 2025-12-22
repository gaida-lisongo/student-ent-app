class Presence {
  final String id;
  final String student;
  final String location;
  final String status;
  final DateTime? createdAt;
  final DateTime? timeRecorded;

  Presence({
    required this.id,
    required this.student,
    required this.location,
    required this.status,
    this.createdAt,
    this.timeRecorded,
  });

  factory Presence.fromJson(Map<String, dynamic> json) {
    return Presence(
      id: json['_id'] as String,
      student: json['student'] as String,
      location: json['location'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      timeRecorded: json['timeRecorded'] != null
          ? DateTime.parse(json['timeRecorded'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'student': student,
      'location': location,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'timeRecorded': timeRecorded?.toIso8601String(),
    };
  }
}

class Seance {
  final String id;
  final String startTime;
  final String endTime;
  final String topic;
  final String location;
  final DateTime date;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Presence> presences;

  Seance({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.topic,
    required this.location,
    required this.date,
    required this.description,
    this.createdAt,
    this.updatedAt,
    required this.presences,
  });

  factory Seance.fromJson(Map<String, dynamic> json) {
    return Seance(
      id: json['_id'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      topic: json['topic'] as String,
      location: json['location'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      presences:
          (json['presences'] as List<dynamic>?)
              ?.map((i) => Presence.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'startTime': startTime,
      'endTime': endTime,
      'topic': topic,
      'location': location,
      'date': date.toIso8601String(),
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'presences': presences,
    };
  }
}
