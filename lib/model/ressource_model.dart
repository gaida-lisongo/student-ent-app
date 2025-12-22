class Ressource {
  final String id;
  final String title;
  final String url;
  final double montant;
  final String description;
  final List<String> commandes;
  final DateTime? createdAt;

  Ressource({
    required this.id,
    required this.title,
    required this.url,
    required this.montant,
    required this.description,
    required this.commandes,
    this.createdAt,
  });

  factory Ressource.fromJson(Map<String, dynamic> json) {
    return Ressource(
      id: json['_id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      montant: (json['montant'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      commandes:
          (json['commandes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'url': url,
      'montant': montant,
      'description': description,
      'commandes': commandes,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
