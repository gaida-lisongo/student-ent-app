// --- Modèle Principal de la Session Utilisateur (Inscription) ---
import 'package:student_app/model/annee_model.dart';
import 'package:student_app/model/notes_model.dart';
import 'package:student_app/model/promotion_model.dart';
import 'package:student_app/model/student_model.dart';

class InscriptionData {
  final String id;
  final Etudiant etudiant;
  final Promotion promotion;
  final Annee annee;
  final String statut;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Note>? notes;

  InscriptionData({
    required this.id,
    required this.etudiant,
    required this.promotion,
    required this.annee,
    required this.statut,
    this.createdAt,
    this.updatedAt,
    this.notes,
  });

  factory InscriptionData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    return InscriptionData(
      id: data['_id'] as String,
      etudiant: Etudiant.fromJson(data['etudiantId'] as Map<String, dynamic>),
      promotion: Promotion.fromJson(
        data['promotionId'] as Map<String, dynamic>,
      ),
      annee: Annee.fromJson(data['anneeId'] as Map<String, dynamic>),
      statut: data['statut'] as String? ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'] as String)
          : null,
      updatedAt: data['updatedAt'] != null
          ? DateTime.parse(data['updatedAt'] as String)
          : null,
      notes: data['notes'] != null
          ? (data['notes'] as List<dynamic>)
                .map(
                  (noteJson) => Note.fromJson(noteJson as Map<String, dynamic>),
                )
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'etudiantId': etudiant.toJson(),
      'promotionId': promotion.toJson(),
      'anneeId': annee.toJson(),
      'statut': statut,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'notes': notes?.map((note) => note.toJson()).toList() ?? [],
    };
  }
}
