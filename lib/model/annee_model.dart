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
