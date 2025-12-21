import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/components/custom_button.dart';
import 'package:student_app/model/recharge_model.dart';
import 'package:student_app/stores/recharge_provider.dart';

class RechargeCard extends ConsumerWidget {
  final Recharge recharge;

  const RechargeCard({super.key, required this.recharge});

  // Fonction utilitaire pour formater les dates ISO
  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'N/A';

    try {
      DateTime date;
      if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return 'N/A';
      }

      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Format invalide';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color statusColor;
    IconData statusIcon;

    switch (recharge.status) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
      case 'failed':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec bouton de vérification
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bouton vérifier en haut à gauche
              IconButton(
                onPressed: () => _verifyTransaction(context, ref),
                icon: const Icon(Icons.refresh, color: Colors.blue),
                tooltip: 'Vérifier le statut',
              ),
              // Statut à droite
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    recharge.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Montant
          Text(
            '${recharge.amount.toStringAsFixed(2)} ${recharge.currency}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            recharge.description,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tel: ${recharge.phone}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              Text(
                _formatDate(recharge.createdAt),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Bouton supprimer (seulement si failed ou cancelled)
          if (recharge.status == 'failed' || recharge.status == 'cancelled')
            Align(
              alignment: Alignment.centerRight,
              child: CustomButton(
                title: 'Supprimer',
                icon: Icons.delete,
                onTap: () => _showDeleteConfirmation(context, ref),
              ),
            ),
        ],
      ),
    );
  }

  // Méthode pour vérifier une transaction
  void _verifyTransaction(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Vérification en cours...'),
          ],
        ),
      ),
    );

    try {
      final rechargeNotifier = ref.read(rechargeProvider.notifier);
      final response = await rechargeNotifier.checkRecharge(
        recharge.orderNumber,
      );

      if (context.mounted) {
        Navigator.pop(context); // Fermer le loading
        _showTransactionResult(context, response);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Fermer le loading
        _showTransactionResult(context, {
          'success': false,
          'message': 'Erreur de connexion: $e',
          'data': null,
        });
      }
    }
  }

  // Modal pour afficher le résultat de vérification
  void _showTransactionResult(
    BuildContext context,
    Map<String, dynamic> response,
  ) {
    final bool success = response['success'] == true;
    final String message = response['message'] ?? 'Réponse inconnue';
    final Map<String, dynamic>? data = response['data'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.info,
              color: success ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                success ? 'Transaction trouvée' : 'Vérification',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: success ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            if (data != null) ...[
              const Text(
                'Détails:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Numéro: ${data['orderNumber'] ?? 'N/A'}'),
              Text('Statut: ${data['status'] ?? 'N/A'}'),
              Text(
                'Montant: ${data['amount'] ?? 'N/A'} ${data['currency'] ?? ''}',
              ),
              if (data['createdAt'] != null)
                Text('Créé le: ${_formatDate(data['createdAt'])}'),
              if (data['completedAt'] != null)
                Text('Complété le: ${_formatDate(data['completedAt'])}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // Modal de confirmation de suppression
  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer cette recharge de ${recharge.amount} ${recharge.currency} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Fermer le dialog
              await _deleteRecharge(context, ref);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  // Méthode pour supprimer une recharge
  Future<void> _deleteRecharge(BuildContext context, WidgetRef ref) async {
    try {
      final rechargeNotifier = ref.read(rechargeProvider.notifier);
      final success = await rechargeNotifier.deleteRecharge(recharge.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Recharge supprimée avec succès'
                  : 'Erreur lors de la suppression',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
