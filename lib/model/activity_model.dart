class Resolution {
  final String id;
  final String student;
  final double score;
  final DateTime? createdAt;
  final DateTime? dateSubmited;

  Resolution({
    required this.id,
    required this.student,
    required this.score,
    this.createdAt,
    this.dateSubmited,
  });

  factory Resolution.fromJson(Map<String, dynamic> json) {
    return Resolution(
      id: json['_id'] as String,
      student: json['student'] as String,
      score: (json['score'] as num).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      dateSubmited: json['dateSubmited'] != null
          ? DateTime.parse(json['dateSubmited'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'student': student,
      'score': score,
      'createdAt': createdAt?.toIso8601String(),
      'dateSubmited': dateSubmited?.toIso8601String(),
    };
  }
}

class Activity {
  final String id;
  final String title;
  final String description;
  final double maximumScore;
  final String type;
  final String status;
  final List<Resolution>? resolutions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.maximumScore,
    required this.type,
    required this.status,
    this.resolutions,
    this.createdAt,
    this.updatedAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      maximumScore: (json['maximumScore'] as num).toDouble(),
      type: json['type'] as String? ?? 'exam',
      status: json['status'] as String? ?? 'pending',
      resolutions: json['resolutions'] != null
          ? (json['resolutions'] as List)
                .map((e) => Resolution.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'maximumScore': maximumScore,
      'type': type,
      'status': status,
      'resolutions': resolutions?.map((r) => r.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
