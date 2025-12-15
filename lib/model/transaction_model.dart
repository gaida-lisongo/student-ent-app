// Modèle pour l'étudiant dans la transaction
class EtudiantInfo {
  final String id;
  final String nom;
  final String prenom;
  final String matricule;

  EtudiantInfo({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.matricule,
  });

  factory EtudiantInfo.fromJson(Map<String, dynamic> json) {
    return EtudiantInfo(
      id: json['_id'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      matricule: json['matricule'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'nom': nom, 'prenom': prenom, 'matricule': matricule};
  }
}

// Modèle Transaction adapté à l'API
class Transaction {
  final String id;
  final String currency;
  final String phone;
  final int amount;
  final String description;
  final String status; // 'completed' | 'pending' | 'failed' etc.
  final EtudiantInfo etudiant;
  final String paymentMethod;
  final String orderNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String transactionId;

  Transaction({
    required this.id,
    required this.currency,
    required this.phone,
    required this.amount,
    required this.description,
    required this.status,
    required this.etudiant,
    required this.paymentMethod,
    required this.orderNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.transactionId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    // Gérer le cas où etudiantId est une String (juste l'ID)
    EtudiantInfo etudiantInfo;
    final etudiantIdValue = json['etudiantId'];

    if (etudiantIdValue is Map<String, dynamic>) {
      // C'est un objet complet
      etudiantInfo = EtudiantInfo.fromJson(etudiantIdValue);
    } else if (etudiantIdValue is String) {
      // C'est juste l'ID, créer un objet avec juste l'ID
      etudiantInfo = EtudiantInfo(
        id: etudiantIdValue,
        nom: '',
        prenom: '',
        matricule: '',
      );
    } else {
      // Cas par défaut
      etudiantInfo = EtudiantInfo(id: '', nom: '', prenom: '', matricule: '');
    }

    return Transaction(
      id: json['_id'] as String? ?? '',
      currency: json['currency'] as String? ?? 'CDF',
      phone: json['phone'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      etudiant: etudiantInfo,
      paymentMethod: json['paymentMethod'] as String? ?? 'mobile_money',
      orderNumber: json['orderNumber'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      transactionId: json['transactionId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'currency': currency,
      'phone': phone,
      'amount': amount,
      'description': description,
      'status': status,
      'etudiantId': etudiant.toJson(),
      'paymentMethod': paymentMethod,
      'orderNumber': orderNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'transactionId': transactionId,
    };
  }
}
