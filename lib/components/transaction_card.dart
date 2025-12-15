import 'package:flutter/material.dart';
import 'package:student_app/model/transaction_model.dart';

// Widget pour afficher une carte de transaction (MAIN COMPONENT)
class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onPayment;
  final VoidCallback onCredit;
  final VoidCallback onDelete;
  final VoidCallback onDetails;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onPayment,
    required this.onCredit,
    required this.onDelete,
    required this.onDetails,
  });

  Color _getStatusColor() {
    switch (transaction.status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'ok':
        return Colors.blue;
      case 'no':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel() {
    switch (transaction.status) {
      case 'completed':
        return 'Complétée';
      case 'pending':
        return 'En attente';
      case 'ok':
        return 'Approuvée';
      case 'no':
        return 'Échouée';
      default:
        return 'Inconnu';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec numéro et statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  transaction.orderNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusLabel(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Montant et date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${transaction.amount} ${transaction.currency}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  transaction.createdAt.toString().split('.')[0],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Téléphone
            Text(
              'Téléphone: ${transaction.phone}',
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            // Boutons d'action (Logique conditionnelle)
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // Bouton par défaut avec style cohérent
    Widget buildButton({
      required String title,
      required Color color,
      required VoidCallback onPressed,
      IconData? icon,
    }) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: icon != null
              ? Icon(icon, color: Colors.white, size: 18)
              : const SizedBox.shrink(),
          label: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      );
    }

    switch (transaction.status) {
      case 'pending':
        return Column(
          children: [
            buildButton(
              title: 'Effectuer le Paiement',
              color: Colors.orange.shade700,
              onPressed: onPayment,
              icon: Icons.payment,
            ),
            const SizedBox(height: 8),
            buildButton(
              title: 'Vérifier le Paiement',
              color: Colors.blue.shade700,
              onPressed: onDetails,
              icon: Icons.check_circle_outline,
            ),
          ],
        );
      case 'ok':
        return buildButton(
          title: 'Créditer le Solde',
          color: Colors.blue.shade700,
          onPressed: onCredit,
          icon: Icons.account_balance_wallet,
        );
      case 'no':
      case 'failed':
        return buildButton(
          title: 'Supprimer',
          color: Colors.red.shade700,
          onPressed: onDelete,
          icon: Icons.delete_forever,
        );
      case 'completed':
        return buildButton(
          title: 'Voir les Détails',
          color: Colors.green.shade700,
          onPressed: onDetails,
          icon: Icons.info_outline,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
