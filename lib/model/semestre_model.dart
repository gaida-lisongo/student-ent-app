// --- Modèle du Semestre ---
import 'package:student_app/model/unite_model.dart';

class Semestre {
  final String id;
  final String designation;
  final int credits;
  final List<UniteEnseignement> unites;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Semestre({
    required this.id,
    required this.designation,
    required this.credits,
    required this.unites,
    this.createdAt,
    this.updatedAt,
  });

  factory Semestre.fromJson(Map<String, dynamic> json) {
    return Semestre(
      id: json['_id'] as String,
      designation: json['designation'] as String,
      credits: json['credits'] as int? ?? 0,
      unites:
          (json['unites'] as List<dynamic>?)
              ?.map(
                (i) => UniteEnseignement.fromJson(i as Map<String, dynamic>),
              )
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
      'credits': credits,
      'unites': unites.map((u) => u.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
