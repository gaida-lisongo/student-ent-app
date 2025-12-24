import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/model/recharge_model.dart';
import 'package:student_app/stores/recharge_provider.dart';
import 'package:student_app/stores/student_provider.dart';

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
          // Boutons selon le statut
          if (recharge.status == 'pending')
            Consumer(
              builder: (context, ref, child) {
                final rechargeState = ref.watch(rechargeProvider);
                final isLoading = rechargeState.isLoading;

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => _makePayment(context, ref),
                    icon: isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.payment, color: Colors.white),
                    label: Text(
                      isLoading ? 'Traitement...' : 'Effectuer le paiement',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLoading ? Colors.grey : Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                );
              },
            )
          else if (recharge.status == 'completed' ||
              recharge.status == 'failed' ||
              recharge.status == 'cancelled')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showDeleteConfirmation(context, ref),
                icon: const Icon(Icons.delete, color: Colors.white),
                label: const Text(
                  'Supprimer',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
        recharge.orderNumber ?? 'N/A',
      );

      if (context.mounted) {
        Navigator.pop(context); // Fermer le loading
        _showTransactionResult(context, ref, response);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Fermer le loading
        _showTransactionResult(context, ref, {
          'success': false,
          'message': 'Erreur de connexion: $e',
          'data': null,
        });
      }
    }
  }

  // Méthode pour effectuer le paiement
  void _makePayment(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.payment, color: Colors.green),
            SizedBox(width: 8),
            Text('Paiement'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recharge de ${recharge.amount.toStringAsFixed(2)} ${recharge.currency}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text('Numéro: ${recharge.phone}'),
            Text('Description: ${recharge.description}'),
            const SizedBox(height: 12),
            const Text(
              'Vous allez être redirigé vers votre plateforme de paiement mobile pour effectuer cette transaction.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPayment(context, ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Procéder au paiement'),
          ),
        ],
      ),
    );
  }

  // Traitement du paiement
  void _processPayment(BuildContext context, WidgetRef ref) async {
    try {
      final rechargeNotifier = ref.read(rechargeProvider.notifier);
      await rechargeNotifier.createPaymement(
        currency: recharge.currency,
        phone: recharge.phone,
        amount: recharge.amount,
        description: recharge.description,
        id: recharge.id,
      );

      print("Paiement initié avec succès");

      // Afficher le message de succès
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paiement initié avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Erreur lors du paiement: $e");

      // Afficher le message d'erreur
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Modal pour afficher le résultat de vérification
  void _showTransactionResult(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> response,
  ) {
    final bool success = response['success'] == true;
    final String message = response['message'] ?? 'Réponse inconnue';
    final Map<String, dynamic>? data = response['data'];
    final bool hasNewBalance = data != null && data['newBalance'] != null;
    final bool isCompleted = data != null && data['status'] == 'completed';
    final bool needsCreditButton = success && hasNewBalance && isCompleted;

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
                success ? 'Transaction vérifiée' : 'Vérification',
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
            if (hasNewBalance) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Nouveau solde: ${(data['newBalance'] as num).toStringAsFixed(2)} CDF',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
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
          if (needsCreditButton)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _creditUser(context, ref, data);
              },
              icon: const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
              ),
              label: const Text(
                'Créditer le compte',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // Créditer manuellement l'utilisateur
  void _creditUser(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> data,
  ) {
    final newBalance = (data['newBalance'] as num).toDouble();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créditer le compte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recharge de ${recharge.amount.toStringAsFixed(2)} ${recharge.currency} terminée !',
            ),
            const SizedBox(height: 8),
            Text(
              'Nouveau solde disponible: ${newBalance.toStringAsFixed(2)} CDF',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Voulez-vous mettre à jour votre solde local avec cette valeur ?',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final etudiantState = ref.read(etudiantProvider); // AsyncValue
              final etudiantNotifier = ref.read(
                etudiantProvider.notifier,
              ); // Notifier

              etudiantState.whenData((etudiant) {
                print(
                  "Mise à jour du solde local à ${etudiant?.solde} -> $newBalance",
                );
                if (etudiant == null) return;

                final updatedEtudiant = etudiant.copyWith(
                  solde:
                      newBalance, // attention, dans ton modèle c’est "solde" pas "balance"
                );

                print("New Etudiant Solde: ${updatedEtudiant.solde}");
                etudiantNotifier.setEtudiant(updatedEtudiant);
              });

              Navigator.pop(context);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Solde mis à jour: ${newBalance.toStringAsFixed(2)} CDF',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer'),
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
