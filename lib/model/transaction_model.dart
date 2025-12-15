// 2. Modèle Transaction (inchangé)
class Transaction {
  final String id;
  final String orderNumber;
  final String dateCreated;
  final double amount;
  final String currency;
  final String status; // 'completed' | 'pending' | 'ok' | 'no'
  final String phone;

  Transaction({
    required this.id,
    required this.orderNumber,
    required this.dateCreated,
    required this.amount,
    required this.currency,
    required this.status,
    required this.phone,
  });
}
