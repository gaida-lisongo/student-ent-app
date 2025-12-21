// --- Modèle de la Promotion ---
import 'package:student_app/model/semestre_model.dart';

class Promotion {
  final String id;
  final String designation;
  final String systeme;
  final String niveau;
  final String cycle;
  final List<Semestre> semestres;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Promotion({
    required this.id,
    required this.designation,
    required this.systeme,
    required this.niveau,
    required this.cycle,
    required this.semestres,
    this.createdAt,
    this.updatedAt,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['_id'] as String,
      designation: json['designation'] as String,
      systeme: json['systeme'] as String? ?? '',
      niveau: json['niveau'] as String? ?? '',
      cycle: json['cycle'] as String? ?? '',
      semestres:
          (json['semestres'] as List<dynamic>?)
              ?.map((i) => Semestre.fromJson(i as Map<String, dynamic>))
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
      'systeme': systeme,
      'niveau': niveau,
      'cycle': cycle,
      'semestres': semestres.map((s) => s.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
