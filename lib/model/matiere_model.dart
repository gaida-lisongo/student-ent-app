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
