import 'package:student_app/model/activity_model.dart';
import 'package:student_app/model/annee_model.dart';
import 'package:student_app/model/matiere_model.dart';
import 'package:student_app/model/ressource_model.dart';
import 'package:student_app/model/seance_model.dart';

class Enseignant {
  final String id;
  final String nom;
  final String postNom;
  final String sexe;
  final String matricule;
  final String prenom;
  final String grade;
  final String email;
  final String telephone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Enseignant({
    required this.id,
    required this.nom,
    required this.postNom,
    required this.sexe,
    required this.matricule,
    required this.prenom,
    required this.grade,
    required this.email,
    required this.telephone,
    this.createdAt,
    this.updatedAt,
  });

  factory Enseignant.fromJson(Map<String, dynamic> json) {
    return Enseignant(
      id: json['_id'] as String,
      nom: json['nom'] as String,
      postNom: json['post_nom'] as String,
      sexe: json['sexe'] as String,
      matricule: json['matricule'] as String,
      grade: json['grade'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
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
      'nom': nom,
      'post_nom': postNom,
      'sexe': sexe,
      'matricule': matricule,
      'grade': grade,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class Charge {
  final String id;
  final Matiere cours;
  final Annee anneeId;
  final Enseignant enseignant;
  final String evaluation;
  final String objectif;
  final String methodologie;
  final String contenu;
  final String references;
  final List<Activity>? activities;
  final List<Seance>? seances;
  final List<Ressource>? ressources;

  Charge({
    required this.id,
    required this.cours,
    required this.anneeId,
    required this.enseignant,
    required this.evaluation,
    required this.objectif,
    required this.methodologie,
    required this.contenu,
    required this.references,
    this.activities,
    this.seances,
    this.ressources,
  });

  factory Charge.fromJson(Map<String, dynamic> json) {
    return Charge(
      id: json['_id'] as String,
      cours: Matiere.fromJson(json['cours'] as Map<String, dynamic>),
      anneeId: Annee.fromJson(json['anneeId'] as Map<String, dynamic>),
      enseignant: Enseignant.fromJson(
        json['enseignantId'] as Map<String, dynamic>,
      ),
      evaluation: json['evaluation'] as String? ?? '',
      objectif: json['objectif'] as String? ?? '',
      methodologie: json['methodologie'] as String? ?? '',
      contenu: json['contenu'] as String? ?? '',
      references: json['references'] as String? ?? '',
      activities: json['activities'] != null
          ? (json['activities'] as List<dynamic>)
                .map(
                  (activityJson) =>
                      Activity.fromJson(activityJson as Map<String, dynamic>),
                )
                .toList()
          : [],
      seances: json['seances'] != null
          ? (json['seances'] as List<dynamic>)
                .map(
                  (seanceJson) =>
                      Seance.fromJson(seanceJson as Map<String, dynamic>),
                )
                .toList()
          : [],
      ressources: json['ressources'] != null
          ? (json['ressources'] as List<dynamic>)
                .map(
                  (ressourceJson) =>
                      Ressource.fromJson(ressourceJson as Map<String, dynamic>),
                )
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'cours': cours.toJson(),
      'anneeId': anneeId.toJson(),
      'enseignantId': enseignant.toJson(),
      'evaluation': evaluation,
      'objectif': objectif,
      'methodologie': methodologie,
      'contenu': contenu,
      'references': references,
      'activities': activities?.map((a) => a.toJson()).toList(),
      'seances': seances?.map((s) => s.toJson()).toList(),
      'ressources': ressources?.map((r) => r.toJson()).toList(),
    };
  }
}
