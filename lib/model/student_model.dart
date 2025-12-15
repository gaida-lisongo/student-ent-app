// --- Modèle d'une Matière ---
class Matiere {
  final String id;
  final String designation;
  final String code;
  final String descriptions;
  final int credits;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Matiere({
    required this.id,
    required this.designation,
    required this.code,
    required this.descriptions,
    required this.credits,
    this.createdAt,
    this.updatedAt,
  });

  factory Matiere.fromJson(Map<String, dynamic> json) {
    return Matiere(
      id: json['_id'] as String,
      designation: json['designation'] as String,
      code: json['code'] as String,
      descriptions: json['descriptions'] as String? ?? '',
      credits: json['credits'] as int? ?? 0,
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
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

// --- Modèle d'une Unité d'Enseignement ---
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

// --- Modèle du Semestre ---
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

// --- Modèle de la Promotion ---
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

// --- Modèle de l'Année Académique ---
class Annee {
  final String id;
  final int debut;
  final int fin;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Annee({
    required this.id,
    required this.debut,
    required this.fin,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Annee.fromJson(Map<String, dynamic> json) {
    return Annee(
      id: json['_id'] as String,
      debut: json['debut'] as int? ?? 0,
      fin: json['fin'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? false,
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
      'debut': debut,
      'fin': fin,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

// --- Modèle de l'Étudiant (Informations Personnelles) ---
class EtudiantPersonnel {
  final String id;
  final String nom;
  final String postNom;
  final String prenom;
  final String matricule;
  final String secure;
  final String sexe;
  final DateTime? dateNaissance;
  final String? lieuNaissance;
  final String? nationalite;
  final String? photo;
  final int solde;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EtudiantPersonnel({
    required this.id,
    required this.nom,
    required this.postNom,
    required this.prenom,
    required this.matricule,
    required this.secure,
    required this.sexe,
    required this.solde,
    this.dateNaissance,
    this.lieuNaissance,
    this.nationalite,
    this.photo,
    this.createdAt,
    this.updatedAt,
  });

  factory EtudiantPersonnel.fromJson(Map<String, dynamic> json) {
    return EtudiantPersonnel(
      id: json['_id'] as String,
      nom: json['nom'] as String? ?? '',
      postNom: json['post_nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      matricule: json['matricule'] as String? ?? '',
      secure: json['secure'] as String? ?? '',
      sexe: json['sexe'] as String? ?? '',
      solde: json['solde'] as int? ?? 0,
      dateNaissance: json['date_naissance'] != null
          ? DateTime.parse(json['date_naissance'] as String)
          : null,
      lieuNaissance: json['lieu_naissance'] as String?,
      nationalite: json['nationalite'] as String?,
      photo: json['photo'] as String?,
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
      'prenom': prenom,
      'matricule': matricule,
      'secure': secure,
      'sexe': sexe,
      'date_naissance': dateNaissance?.toIso8601String(),
      'lieu_naissance': lieuNaissance,
      'nationalite': nationalite,
      'photo': photo,
      'solde': solde,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

// --- Modèle Principal de la Session Utilisateur (Inscription) ---
class InscriptionData {
  final String id;
  final EtudiantPersonnel etudiant;
  final Promotion promotion;
  final Annee annee;
  final String statut;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  InscriptionData({
    required this.id,
    required this.etudiant,
    required this.promotion,
    required this.annee,
    required this.statut,
    this.createdAt,
    this.updatedAt,
  });

  factory InscriptionData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    return InscriptionData(
      id: data['_id'] as String,
      etudiant: EtudiantPersonnel.fromJson(
        data['etudiantId'] as Map<String, dynamic>,
      ),
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
    };
  }
}

// --- Modèle de réponse API ---
class ApiResponse<T> {
  final bool success;
  final T data;

  ApiResponse({required this.success, required this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] as T,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data};
  }
}
