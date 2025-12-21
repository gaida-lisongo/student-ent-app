class Recharge {
  final String id;
  final String etudiantId;
  final double amount;
  final String currency;
  final String phone;
  final String description;
  final String paymentMethode;
  final String orderNumber;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Recharge({
    required this.id,
    required this.etudiantId,
    required this.amount,
    required this.currency,
    required this.phone,
    required this.description,
    required this.paymentMethode,
    required this.orderNumber,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Recharge.fromJson(Map<String, dynamic> json) {
    return Recharge(
      id: json['_id'] as String,
      etudiantId: json['etudiantId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'XOF',
      phone: json['phone'] as String,
      description: json['description'] as String? ?? '',
      paymentMethode: json['paymentMethode'] as String,
      orderNumber: json['orderNumber'] as String,
      status: json['status'] as String,
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
      'etudiantId': etudiantId,
      'amount': amount,
      'currency': currency,
      'phone': phone,
      'description': description,
      'paymentMethode': paymentMethode,
      'orderNumber': orderNumber,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Recharge copyWith({
    String? id,
    String? etudiantId,
    double? amount,
    String? currency,
    String? phone,
    String? description,
    String? paymentMethode,
    String? orderNumber,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recharge(
      id: id ?? this.id,
      etudiantId: etudiantId ?? this.etudiantId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      phone: phone ?? this.phone,
      description: description ?? this.description,
      paymentMethode: paymentMethode ?? this.paymentMethode,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recharge &&
        other.id == id &&
        other.etudiantId == etudiantId &&
        other.amount == amount &&
        other.currency == currency &&
        other.phone == phone &&
        other.description == description &&
        other.paymentMethode == paymentMethode &&
        other.orderNumber == orderNumber &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      etudiantId,
      amount,
      currency,
      phone,
      description,
      paymentMethode,
      orderNumber,
      status,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'Recharge(id: $id, etudiantId: $etudiantId, amount: $amount, currency: $currency, phone: $phone, description: $description, paymentMethode: $paymentMethode, orderNumber: $orderNumber, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
