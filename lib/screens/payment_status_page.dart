import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/stores/recharge_provider.dart';
import 'package:student_app/services/transaction_service.dart';

class PaymentStatusPage extends ConsumerStatefulWidget {
  final String orderNumber;
  final int amount;
  final String currency;

  const PaymentStatusPage({
    super.key,
    required this.orderNumber,
    required this.amount,
    required this.currency,
  });

  @override
  ConsumerState<PaymentStatusPage> createState() => _PaymentStatusPageState();
}

class _PaymentStatusPageState extends ConsumerState<PaymentStatusPage> {
  bool _isVerifying = false;

  void _verifyPayment() async {
    setState(() {
      _isVerifying = true;
    });

    // Attendre un moment avant de vérifier (le paiement peut prendre du temps)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Vérifier le statut
    ref.refresh(checkRechargeStatusProvider(widget.orderNumber));
  }

  @override
  void initState() {
    super.initState();
    // Vérifier automatiquement après 3 secondes
    Future.delayed(const Duration(seconds: 3), _verifyPayment);
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(
      checkRechargeStatusProvider(widget.orderNumber),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statut du Paiement'),
        centerTitle: true,
        elevation: 0,
      ),
      body: statusAsync.when(
        data: (status) {
          return _buildStatusContent(context, status);
        },
        loading: () {
          return _buildLoadingContent();
        },
        error: (error, stackTrace) {
          return _buildErrorContent(context, error);
        },
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          const Text(
            'Vérification du paiement en cours...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Détails de la recharge:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text('Numéro de commande: ${widget.orderNumber}'),
                const SizedBox(height: 4),
                Text('Montant: ${widget.amount} ${widget.currency}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusContent(BuildContext context, RechargeStatus status) {
    final isSuccess = status.status == 'completed';
    final isFailed = status.status == 'failed';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icône de statut
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSuccess
                    ? Colors.green.withOpacity(0.1)
                    : isFailed
                    ? Colors.red.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
              ),
              child: Center(
                child: Icon(
                  isSuccess
                      ? Icons.check_circle
                      : isFailed
                      ? Icons.cancel
                      : Icons.schedule,
                  size: 60,
                  color: isSuccess
                      ? Colors.green
                      : isFailed
                      ? Colors.red
                      : Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Titre selon le statut
            Text(
              isSuccess
                  ? 'Paiement Reçu!'
                  : isFailed
                  ? 'Paiement Échoué'
                  : 'Paiement en Attente',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSuccess
                    ? Colors.green
                    : isFailed
                    ? Colors.red
                    : Colors.orange,
              ),
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              status.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Détails
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Numéro de Commande', status.orderNumber),
                  const Divider(),
                  _buildDetailRow(
                    'Montant',
                    '${status.amount} ${status.currency}',
                  ),
                  const Divider(),
                  _buildDetailRow('Statut', status.status.toUpperCase()),
                  if (status.newBalance != null) ...[
                    const Divider(),
                    _buildDetailRow(
                      'Nouveau Solde',
                      '${status.newBalance} ${status.currency}',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Boutons d'action
            if (isFailed) ...[
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Text(
                  'Nous n\'avons pas reçu votre paiement. Veuillez réessayer avec un autre numéro ou montant.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Retourner à la bottom sheet
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Faire une Nouvelle Recharge',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ] else if (!isSuccess) ...[
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Text(
                  'Votre paiement est en cours de traitement. Veuillez patienter.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orange, fontSize: 14),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Vérifier à Nouveau',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: const Text(
                  'Votre solde a été crédité avec succès!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Retourner au dashboard
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Retour au Tableau de Bord',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.1),
              ),
              child: const Center(
                child: Icon(Icons.error_outline, size: 60, color: Colors.red),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Erreur de Vérification',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Retour',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
