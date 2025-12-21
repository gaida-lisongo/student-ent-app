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
  final int solde;
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
