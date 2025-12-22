// --- Modèle de l'Étudiant (Informations Personnelles) ---
class Etudiant {
  final String id;
  final String nom;
  final String postNom;
  final String prenom;
  final String matricule;
  final String sexe;
  final DateTime? dateNaissance;
  final String? lieuNaissance;
  final String? nationalite;
  final String? photo;
  final String? telephone;
  final String? email;
  final String? adresse;
  final double solde;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Etudiant({
    required this.id,
    required this.nom,
    required this.postNom,
    required this.prenom,
    required this.matricule,
    required this.sexe,
    required this.solde,
    this.dateNaissance,
    this.lieuNaissance,
    this.nationalite,
    this.photo,
    this.telephone,
    this.email,
    this.adresse,
    this.createdAt,
    this.updatedAt,
  });

  factory Etudiant.fromJson(Map<String, dynamic> json) {
    return Etudiant(
      id: json['_id'] as String,
      nom: json['nom'] as String? ?? '',
      postNom: json['post_nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      matricule: json['matricule'] as String? ?? '',
      sexe: json['sexe'] as String? ?? '',
      solde: (json['solde'] as num?)?.toDouble() ?? 0,
      dateNaissance: json['date_naissance'] != null
          ? DateTime.parse(json['date_naissance'] as String)
          : null,
      lieuNaissance: json['lieu_naissance'] as String?,
      nationalite: json['nationalite'] as String?,
      photo: json['photo'] as String?,
      telephone:
          json['telephone'] as String?, // Peut être null si pas dans la réponse
      email: json['email'] as String?, // Peut être null si pas dans la réponse
      adresse:
          json['adresse'] as String?, // Peut être null si pas dans la réponse
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
      'sexe': sexe,
      'date_naissance': dateNaissance?.toIso8601String(),
      'lieu_naissance': lieuNaissance,
      'nationalite': nationalite,
      'photo': photo,
      'telephone': telephone,
      'email': email,
      'adresse': adresse,
      'solde': solde,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Etudiant copyWith({
    String? id,
    String? nom,
    String? postNom,
    String? prenom,
    String? matricule,
    String? sexe,
    DateTime? dateNaissance,
    String? lieuNaissance,
    String? nationalite,
    String? photo,
    String? telephone,
    String? email,
    String? adresse,
    double? solde,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Etudiant(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      postNom: postNom ?? this.postNom,
      prenom: prenom ?? this.prenom,
      matricule: matricule ?? this.matricule,
      sexe: sexe ?? this.sexe,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      lieuNaissance: lieuNaissance ?? this.lieuNaissance,
      nationalite: nationalite ?? this.nationalite,
      photo: photo ?? this.photo,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      adresse: adresse ?? this.adresse,
      solde: solde ?? this.solde,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Etudiant &&
        other.id == id &&
        other.nom == nom &&
        other.postNom == postNom &&
        other.prenom == prenom &&
        other.matricule == matricule &&
        other.sexe == sexe &&
        other.dateNaissance == dateNaissance &&
        other.lieuNaissance == lieuNaissance &&
        other.nationalite == nationalite &&
        other.photo == photo &&
        other.telephone == telephone &&
        other.email == email &&
        other.adresse == adresse &&
        other.solde == solde &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      nom,
      postNom,
      prenom,
      matricule,
      sexe,
      dateNaissance,
      lieuNaissance,
      nationalite,
      photo,
      telephone,
      email,
      adresse,
      solde,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'Etudiant(id: $id, nom: $nom, postNom: $postNom, prenom: $prenom, matricule: $matricule, sexe: $sexe, dateNaissance: $dateNaissance, lieuNaissance: $lieuNaissance, nationalite: $nationalite, photo: $photo, telephone: $telephone, email: $email, adresse: $adresse, solde: $solde, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  // Getter pour l'ID conforme au pattern existant
  String get _id => id;

  // Getter pour le nom complet
  String get nomComplet => '$prenom $nom $postNom'.trim();

  // Getter pour l'âge (si date de naissance disponible)
  int? get age {
    if (dateNaissance == null) return null;
    final now = DateTime.now();
    int age = now.year - dateNaissance!.year;
    if (now.month < dateNaissance!.month ||
        (now.month == dateNaissance!.month && now.day < dateNaissance!.day)) {
      age--;
    }
    return age;
  }
}
