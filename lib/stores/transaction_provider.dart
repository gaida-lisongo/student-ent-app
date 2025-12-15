import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/services/transaction_service.dart';
import 'package:student_app/model/transaction_model.dart';
import 'package:student_app/stores/autth_provider.dart';

// Instance du service de transaction
final transactionServiceProvider = Provider((ref) {
  return TransactionService();
});

// Provider pour les recharges de l'étudiant
final studentRechargesProvider =
    FutureProvider.family<List<Transaction>, String>((ref, etudiantId) async {
      final transactionService = ref.watch(transactionServiceProvider);

      try {
        final response = await transactionService.getStudentRecharges(
          etudiantId: etudiantId,
          limit: 50,
        );
        return response.data;
      } catch (e) {
        print('Erreur lors de la récupération des recharges: $e');
        rethrow;
      }
    });

// Provider pour les recharges de l'utilisateur authentifié (à utiliser dans le dashboard)
final userRechargesProvider = FutureProvider<List<Transaction>>((ref) async {
  final authState = ref.watch(authProvider);

  if (authState.user == null) {
    return [];
  }

  final etudiantId = authState.user!.etudiant.id;
  return ref.watch(studentRechargesProvider(etudiantId).future);
});

// Provider pour créer une recharge
final createRechargeProvider =
    FutureProvider.family<Transaction, Map<String, dynamic>>((
      ref,
      params,
    ) async {
      final transactionService = ref.watch(transactionServiceProvider);

      final etudiantId = params['etudiantId'] as String;
      final amount = params['amount'] as int;
      final phone = params['phone'] as String;
      final description = params['description'] as String? ?? '';
      final currency = params['currency'] as String? ?? 'CDF';
      final paymentMethod =
          params['paymentMethod'] as String? ?? 'mobile_money';

      final transaction = await transactionService.createRecharge(
        etudiantId: etudiantId,
        amount: amount,
        phone: phone,
        description: description,
        currency: currency,
        paymentMethod: paymentMethod,
      );

      // Invalider le cache des recharges après création
      ref.invalidate(studentRechargesProvider(etudiantId));

      return transaction;
    });

// Provider pour effectuer le paiement d'une recharge
final payRechargeProvider =
    FutureProvider.family<Transaction, Map<String, dynamic>>((
      ref,
      params,
    ) async {
      final transactionService = ref.watch(transactionServiceProvider);

      final rechargeId = params['rechargeId'] as String;
      final transactionData = params['transactionData'] as Map<String, dynamic>;

      final transaction = await transactionService.payRecharge(
        rechargeId: rechargeId,
        transactionData: transactionData,
      );

      // Invalider le cache après le paiement
      final etudiantId = transactionData['etudiantId'] as String? ?? '';
      if (etudiantId.isNotEmpty) {
        ref.invalidate(studentRechargesProvider(etudiantId));
      }

      return transaction;
    });

// Provider pour vérifier le statut d'une recharge
final checkRechargeStatusProvider =
    FutureProvider.family<RechargeStatus, String>((ref, orderNumber) async {
      final transactionService = ref.watch(transactionServiceProvider);
      return await transactionService.checkRechargeStatus(orderNumber);
    });
