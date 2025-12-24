
abstract class ActivityData {
  Map<String, dynamic> toJson();
}

class AttachedFile {
  final String name;
  final String url;
  final String type;

  AttachedFile({required this.name, required this.url, required this.type});

  factory AttachedFile.fromJson(Map<String, dynamic> json) {
    return AttachedFile(
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
        'type': type,
      };
}

class DevoirData implements ActivityData {
  final String? url;
  final String? typeFile;

  DevoirData({this.url, this.typeFile});

  factory DevoirData.fromJson(Map<String, dynamic> json) {
    return DevoirData(
      url: json['url'] as String?,
      typeFile: json['typeFile'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'url': url,
        'typeFile': typeFile,
      };
}

class TPQuestionnaire {
  final String? id;
  final String title;
  final String description;
  final num points;
  final AttachedFile? attachedFile;

  TPQuestionnaire({
    this.id,
    required this.title,
    required this.description,
    required this.points,
    this.attachedFile,
  });

  factory TPQuestionnaire.fromJson(Map<String, dynamic> json) {
    return TPQuestionnaire(
      id: json['_id'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      points: json['points'] as num? ?? 0,
      attachedFile: json['attachedFile'] != null
          ? AttachedFile.fromJson(json['attachedFile'])
          : null,
    );
  }
}

class TPData implements ActivityData {
  final List<TPQuestionnaire> questionnaires;

  TPData({required this.questionnaires});

  factory TPData.fromJson(Map<String, dynamic> json) {
    return TPData(
      questionnaires: (json['questionnaires'] as List<dynamic>?)
              ?.map((e) => TPQuestionnaire.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'questionnaires': questionnaires.map((e) => {
          'title': e.title,
          'description': e.description,
          'points': e.points,
          'attachedFile': e.attachedFile?.toJson(),
        }).toList(),
      };
}

class ProjetProblematic {
  final String? id;
  final String title;
  final String description;
  final AttachedFile? attachedFile;

  ProjetProblematic({
    this.id,
    required this.title,
    required this.description,
    this.attachedFile,
  });

  factory ProjetProblematic.fromJson(Map<String, dynamic> json) {
    return ProjetProblematic(
      id: json['_id'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      attachedFile: json['attachedFile'] != null
          ? AttachedFile.fromJson(json['attachedFile'])
          : null,
    );
  }
}

class ProjetData implements ActivityData {
  final String contexte;
  final List<ProjetProblematic> problematiques;

  ProjetData({required this.contexte, required this.problematiques});

  factory ProjetData.fromJson(Map<String, dynamic> json) {
    return ProjetData(
      contexte: json['contexte'] as String? ?? '',
      problematiques: (json['problematiques'] as List<dynamic>?)
              ?.map((e) => ProjetProblematic.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'contexte': contexte,
        'problematiques': problematiques.map((e) => {
          'title': e.title,
          'description': e.description,
          'attachedFile': e.attachedFile?.toJson(),
        }).toList(),
      };
}

class QCMOption {
  final String text;
  final bool isCorrect; 

  QCMOption({required this.text, required this.isCorrect});

  factory QCMOption.fromJson(Map<String, dynamic> json) {
    return QCMOption(
      text: json['text']?.toString() ?? '',
      isCorrect: json['isCorrect'] as bool? ?? false,
    );
  }
}

class QCMQuestion {
  final String questionText;
  final List<QCMOption> options;
  final num points;

  QCMQuestion({
    required this.questionText,
    required this.options,
    required this.points,
  });

  factory QCMQuestion.fromJson(Map<String, dynamic> json) {
    return QCMQuestion(
      questionText: json['questionText'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => QCMOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      points: json['points'] as num? ?? 0,
    );
  }
}

class QCMData implements ActivityData {
  final List<QCMQuestion> questions;

  QCMData({required this.questions});

  factory QCMData.fromJson(Map<String, dynamic> json) {
    return QCMData(
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => QCMQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'questions': questions.map((e) => {
          'questionText': e.questionText,
          'options': e.options.map((o) => {'text': o.text, 'isCorrect': o.isCorrect}).toList(),
        }).toList(),
      };
}

class Questionnaire {
  final String id;
  final String activityId;
  final String status;
  final DateTime dateRemise;
  final num maximumScore;
  final DevoirData? devoir;
  final TPData? tp;
  final ProjetData? projet;
  final QCMData? qcm;
  final String activityType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Questionnaire({
    required this.id,
    required this.activityId,
    required this.activityType,
    required this.status,
    required this.dateRemise,
    required this.maximumScore,
    this.devoir,
    this.tp,
    this.projet,
    this.qcm,
    this.createdAt,
    this.updatedAt,
  });

  factory Questionnaire.fromJson(Map<String, dynamic> json) {
    String actId = '';
    String actType = '';
    
    final rawActivityId = json['activityId'];
    if (rawActivityId is Map) {
      actId = (rawActivityId['_id'] ?? '').toString();
      actType = (rawActivityId['type'] ?? '').toString();
    } else if (rawActivityId is String) {
      actId = rawActivityId;
    }

    return Questionnaire(
      id: (json['_id'] ?? '').toString(),
      activityId: actId,
      activityType: actType,
      status: json['status']?.toString() ?? 'pending',
      dateRemise: DateTime.tryParse(json['dateRemise']?.toString() ?? '') ?? DateTime.now(),
      maximumScore: json['maximumScore'] as num? ?? 0,
      devoir: json['devoir'] is Map && (json['devoir'] as Map).isNotEmpty ? DevoirData.fromJson(json['devoir']) : null,
      tp: json['tp'] is Map && (json['tp'] as Map).isNotEmpty ? TPData.fromJson(json['tp']) : null,
      projet: json['projet'] is Map && (json['projet'] as Map).isNotEmpty ? ProjetData.fromJson(json['projet']) : null,
      qcm: json['qcm'] is Map && (json['qcm'] as Map).isNotEmpty ? QCMData.fromJson(json['qcm']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'activityId': activityId,
    'activityType': activityType,
    'status': status,
    'dateRemise': dateRemise.toIso8601String(),
    'maximumScore': maximumScore,
    'devoir': devoir?.toJson(),
    'tp': tp?.toJson(),
    'projet': projet?.toJson(),
    'qcm': qcm?.toJson(),
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  //copyWith
  Questionnaire copyWith({
    String? id,
    String? activityId,
    String? activityType,
    String? status,
    DateTime? dateRemise,
    num? maximumScore,
    DevoirData? devoir,
    TPData? tp,
    ProjetData? projet,
    QCMData? qcm,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Questionnaire(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      activityType: activityType ?? this.activityType,
      status: status ?? this.status,
      dateRemise: dateRemise ?? this.dateRemise,
      maximumScore: maximumScore ?? this.maximumScore,
      devoir: devoir ?? this.devoir,
      tp: tp ?? this.tp,
      projet: projet ?? this.projet,
      qcm: qcm ?? this.qcm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
