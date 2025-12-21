// --- Modèle d'une Unité d'Enseignement ---
import 'package:student_app/model/matiere_model.dart';

class UniteEnseignement {
  final String id;
  final String designation;
  final String code;
  final String descriptions;
  final int credits;
  final String filiereId;
  final List<Matiere> matieres;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UniteEnseignement({
    required this.id,
    required this.designation,
    required this.code,
    required this.descriptions,
    required this.credits,
    required this.filiereId,
    required this.matieres,
    this.createdAt,
    this.updatedAt,
  });

  factory UniteEnseignement.fromJson(Map<String, dynamic> json) {
    return UniteEnseignement(
      id: json['_id'] as String,
      designation: json['designation'] as String,
      code: json['code'] as String,
      descriptions: json['descriptions'] as String? ?? 'S/N',
      credits: json['credits'] as int? ?? 0,
      filiereId: json['filiereId'] as String? ?? '',
      matieres:
          (json['matieres'] as List<dynamic>?)
              ?.map((i) => Matiere.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
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
      'designation': designation,
      'code': code,
      'descriptions': descriptions,
      'credits': credits,
      'filiereId': filiereId,
      'matieres': matieres.map((m) => m.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
