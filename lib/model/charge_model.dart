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

  factory Enseignant.empty() {
    return Enseignant(
      id: '',
      nom: '',
      postNom: '',
      sexe: '',
      matricule: '',
      prenom: '',
      grade: '',
      email: '',
      telephone: '',
    );
  }

  factory Enseignant.fromJson(Map<String, dynamic> json) {
    try {
      return Enseignant(
        id: json['_id']?.toString() ?? '',
        nom: JsonParsingUtils.safeGetString(json, 'nom'),
        postNom: JsonParsingUtils.safeGetString(json, 'post_nom'),
        sexe: JsonParsingUtils.safeGetString(json, 'sexe'),
        matricule: JsonParsingUtils.safeGetString(json, 'matricule'),
        grade: JsonParsingUtils.safeGetString(json, 'grade'),
        prenom: JsonParsingUtils.safeGetString(json, 'prenom'),
        email: JsonParsingUtils.safeGetString(json, 'email'),
        telephone: JsonParsingUtils.safeGetString(json, 'telephone'),
        createdAt: JsonParsingUtils.safeParseDateTime(json['createdAt']),
        updatedAt: JsonParsingUtils.safeParseDateTime(json['updatedAt']),
      );
    } catch (e) {
      print('Erreur lors du parsing d\'Enseignant: $e');
      print('JSON reçu: $json');
      rethrow;
    }
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

class Promotion {
  final String id;
  final String designation;
  final String systeme;
  final String niveau;
  final String cycle;
  final List<String> semestres;
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

  factory Promotion.empty() {
    return Promotion(
      id: '',
      designation: '',
      systeme: '',
      niveau: '',
      cycle: '',
      semestres: [],
    );
  }

  factory Promotion.fromJson(Map<String, dynamic> json) {
    try {
      return Promotion(
        id: json['_id']?.toString() ?? '',
        designation: JsonParsingUtils.safeGetString(json, 'designation'),
        systeme: JsonParsingUtils.safeGetString(json, 'systeme'),
        niveau: JsonParsingUtils.safeGetString(json, 'niveau'),
        cycle: JsonParsingUtils.safeGetString(json, 'cycle'),
        semestres: json['semestres'] != null
            ? JsonParsingUtils.safeParseStringList(json['semestres'])
            : [],
        createdAt: JsonParsingUtils.safeParseDateTime(json['createdAt']),
        updatedAt: JsonParsingUtils.safeParseDateTime(json['updatedAt']),
      );
    } catch (e) {
      print('Erreur lors du parsing de Promotion: $e');
      print('JSON reçu: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'designation': designation,
      'systeme': systeme,
      'niveau': niveau,
      'cycle': cycle,
      'semestres': semestres,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class Charge {
  final String id;
  final Matiere cours;
  final Annee anneeId;
  final Promotion? promotionId;
  final Enseignant enseignant;
  final String status;
  final String evaluation;
  final String objectif;
  final String methodologie;
  final String contenu;
  final String references;
  final List<Activity>? activities;
  final List<Seance>? seances;
  final List<Ressource>? ressources;
  final List<dynamic>? recours;
  final List<dynamic>? plannings;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Charge({
    required this.id,
    required this.cours,
    required this.anneeId,
    this.promotionId,
    required this.enseignant,
    required this.status,
    required this.evaluation,
    required this.objectif,
    required this.methodologie,
    required this.contenu,
    required this.references,
    this.activities,
    this.seances,
    this.ressources,
    this.recours,
    this.plannings,
    this.createdAt,
    this.updatedAt,
  });

  factory Charge.empty() {
    return Charge(
      id: '',
      cours: Matiere.empty(),
      anneeId: Annee.empty(),
      promotionId: Promotion.empty(),
      enseignant: Enseignant.empty(),
      status: '',
      evaluation: '',
      objectif: '',
      methodologie: '',
      contenu: '',
      references: '',
      activities: [],
      seances: [],
      ressources: [],
      recours: [],
      plannings: [],
    );
  }

  factory Charge.fromJson(Map<String, dynamic> json) {
    try {
      return Charge(
        id: json['_id']?.toString() ?? '',
        cours: json['cours'] != null
            ? Matiere.fromJson(json['cours'] as Map<String, dynamic>)
            : Matiere.empty(),
        anneeId: json['anneeId'] != null
            ? Annee.fromJson(json['anneeId'] as Map<String, dynamic>)
            : Annee.empty(),
        promotionId: json['promotionId'] != null
            ? Promotion.fromJson(json['promotionId'] as Map<String, dynamic>)
            : null,
        enseignant: json['enseignant'] != null
            ? Enseignant.fromJson(json['enseignant'] as Map<String, dynamic>)
            : Enseignant.empty(),
        status: JsonParsingUtils.safeGetString(json, 'status'),
        evaluation: JsonParsingUtils.safeGetString(json, 'evaluation'),
        objectif: JsonParsingUtils.safeGetString(json, 'objectif'),
        methodologie: JsonParsingUtils.safeGetString(json, 'methodologie'),
        contenu: JsonParsingUtils.safeGetString(json, 'contenu'),
        references: JsonParsingUtils.safeGetString(json, 'references'),
        activities: json['activities'] != null
            ? JsonParsingUtils.safeParseActivities(json['activities'])
            : [],
        seances: json['seances'] != null
            ? JsonParsingUtils.safeParseSeances(json['seances'])
            : [],
        ressources: json['ressources'] != null
            ? JsonParsingUtils.safeParseRessources(json['ressources'])
            : [],
        recours: json['recours'] as List<dynamic>? ?? [],
        plannings: json['plannings'] as List<dynamic>? ?? [],
        createdAt: JsonParsingUtils.safeParseDateTime(json['createdAt']),
        updatedAt: JsonParsingUtils.safeParseDateTime(json['updatedAt']),
      );
    } catch (e) {
      print('Erreur lors du parsing de Charge: $e');
      print('JSON reçu: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'cours': cours.toJson(),
      'anneeId': anneeId.toJson(),
      'promotionId': promotionId?.toJson(),
      'enseignant': enseignant.toJson(),
      'status': status,
      'evaluation': evaluation,
      'objectif': objectif,
      'methodologie': methodologie,
      'contenu': contenu,
      'references': references,
      'activities': activities?.map((a) => a.toJson()).toList(),
      'seances': seances?.map((s) => s.toJson()).toList(),
      'ressources': ressources?.map((r) => r.toJson()).toList(),
      'recours': recours,
      'plannings': plannings,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

// Méthodes utilitaires partagées pour le parsing JSON
class JsonParsingUtils {
  // Méthode utilitaire pour extraire une chaîne de façon sécurisée
  static String safeGetString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map || value is List) {
      print(
        'Attention: $key devrait être une String mais contient: ${value.runtimeType}',
      );
      return '';
    }
    return value.toString();
  }

  // Méthode utilitaire pour parser les dates
  static DateTime? safeParseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    try {
      if (dateValue is String) return DateTime.parse(dateValue);
      return null;
    } catch (e) {
      print('Erreur parsing date: $dateValue');
      return null;
    }
  }

  static List<String> safeParseStringList(dynamic value) {
    try {
      if (value is List) {
        return value.map((item) => item?.toString() ?? '').toList();
      }
      return [];
    } catch (e) {
      print('Erreur parsing string list: $e');
      return [];
    }
  }

  // Méthodes pour parser les listes d'objets spécifiques
  static List<Activity> safeParseActivities(dynamic activities) {
    print('🏃 Début parsing activities');
    print('📊 Type d\'activités reçu: ${activities.runtimeType}');

    try {
      if (activities == null) {
        print('⚠️ Activities est null');
        return [];
      }

      if (activities is List<dynamic>) {
        print('✅ Activities est une liste de ${activities.length} éléments');

        final validActivities = activities.where((item) {
          final isValid = item is Map<String, dynamic>;
          if (!isValid) {
            print('⚠️ Élément ignoré - type: ${item.runtimeType}');
          }
          return isValid;
        }).toList();

        print('📊 ${validActivities.length} activités valides trouvées');

        final parsedActivities = validActivities.map((activityJson) {
          try {
            final activity = Activity.fromJson(
              activityJson as Map<String, dynamic>,
            );
            print('✅ Activité parsée: ${activity.title}');
            return activity;
          } catch (e) {
            print('❌ Erreur parsing activité: $e');
            print('📊 JSON problématique: $activityJson');
            rethrow;
          }
        }).toList();

        print('🎉 ${parsedActivities.length} activités parsées avec succès');
        return parsedActivities;
      } else {
        print('❌ Activities n\'est pas une liste: ${activities.runtimeType}');
        return [];
      }
    } catch (e) {
      print('❌ Erreur parsing activities: $e');
      print('📊 Données problématiques: $activities');
      return [];
    }
  }

  static List<Seance> safeParseSeances(dynamic seances) {
    try {
      if (seances is List<dynamic>) {
        return seances
            .where((item) => item is Map<String, dynamic>)
            .map(
              (seanceJson) =>
                  Seance.fromJson(seanceJson as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Erreur parsing seances: $e');
      return [];
    }
  }

  static List<Ressource> safeParseRessources(dynamic ressources) {
    try {
      if (ressources is List<dynamic>) {
        return ressources
            .where((item) => item is Map<String, dynamic>)
            .map(
              (ressourceJson) =>
                  Ressource.fromJson(ressourceJson as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Erreur parsing ressources: $e');
      return [];
    }
  }
}
