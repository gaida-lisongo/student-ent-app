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
  final ActivityTransaction? transaction;
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
    this.transaction,
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
      transaction: json['transaction'] != null
          ? ActivityTransaction.fromJson(json['transaction'] as Map<String, dynamic>)
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
      'transaction': transaction?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class ActivityTransaction {
  final String id;
  final int amount;
  final String status;
  final List<Subscription> subscriptions;

  ActivityTransaction({
    required this.id,
    required this.amount,
    required this.status,
    required this.subscriptions,
  });

  factory ActivityTransaction.fromJson(Map<String, dynamic> json) {
    return ActivityTransaction(
      id: json['_id'] as String,
      amount: json['amount'] as int? ?? 0,
      status: json['status'] as String? ?? 'Pending',
      subscriptions: (json['subscriptions'] as List<dynamic>?)
              ?.map((e) => Subscription.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'amount': amount,
      'status': status,
      'subscriptions': subscriptions.map((e) => e.toJson()).toList(),
    };
  }
}

class Subscription {
  final String studentId;
  final num lastSolde;
  final num newSolde;

  Subscription({
    required this.studentId,
    required this.lastSolde,
    required this.newSolde,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    // Handle student field which can be an ID (String) or Object (Map)
    String sId = '';
    if (json['student'] is Map) {
      sId = json['student']['_id'] as String;
    } else if (json['student'] is String) {
      sId = json['student'] as String;
    }

    return Subscription(
      studentId: sId,
      lastSolde: json['lastSolde'] as num? ?? 0,
      newSolde: json['newSolde'] as num? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student': studentId,
      'lastSolde': lastSolde,
      'newSolde': newSolde,
    };
  }
}
