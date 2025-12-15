import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
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

      // Rafraîchir les recharges pour une mise à jour fluide et immédiate
      await ref.refresh(studentRechargesProvider(etudiantId).future);

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

// Provider pour supprimer une recharge
final deleteRechargeProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, params) async {
      final transactionService = ref.watch(transactionServiceProvider);
      final rechargeId = params['rechargeId'] as String;
      final etudiantId = params['etudiantId'] as String;

      await transactionService.deleteRecharge(rechargeId);

      // Rafraîchir la liste des recharges après suppression
      await ref.refresh(studentRechargesProvider(etudiantId).future);
    });

// lib/stores/transaction_provider.dart

// ... (Gardez transactionServiceProvider, authProvider, et vos modèles)

// ----------------------------------------------------
// 1. NOTIFIER : Gérer la liste des transactions en mémoire
// ----------------------------------------------------

class UserRechargesNotifier
    extends StateNotifier<AsyncValue<List<Transaction>>> {
  final String etudiantId;
  final TransactionService _transactionService;

  // Utilisation de StateNotifier pour gérer l'état AsyncValue de la liste
  UserRechargesNotifier(this.etudiantId, this._transactionService)
    : super(const AsyncValue.loading()) {
    fetchRecharges(); // Charger la liste au démarrage
  }

  // Fonction de chargement initial et de rafraîchissement
  Future<void> fetchRecharges() async {
    state = const AsyncValue.loading();
    try {
      final response = await _transactionService.getStudentRecharges(
        etudiantId: etudiantId,
        limit: 50,
      );
      // Mettre à jour l'état avec les données
      state = AsyncValue.data(response.data);
    } catch (e, stack) {
      state = AsyncValue.error('Erreur de chargement: $e', stack);
    }
  }

  // Mise à jour locale après AJOUT ou MODIFICATION
  void addTransaction(Transaction transaction) {
    if (state.hasValue) {
      // Mettre le nouvel élément en tête de liste pour l'UX
      final updatedList = [transaction, ...state.value!];
      state = AsyncValue.data(updatedList);
    }
    // Note: Vous pouvez déclencher un `fetchRecharges()` après un délai
    // pour s'assurer que l'état local correspond bien au backend.
  }

  // Mise à jour locale après SUPPRESSION
  void removeTransaction(String transactionId) {
    if (state.hasValue) {
      final updatedList = state.value!
          .where((t) => t.id != transactionId)
          .toList();
      state = AsyncValue.data(updatedList);
    }
  }

  // Mise à jour locale après MODIFICATION (ex: changement d'orderNumber, de statut, ou de montant)
  void updateTransaction(Transaction updatedTransaction) {
    if (state.hasValue) {
      final List<Transaction> currentList = state.value!;

      // Trouver l'index de l'ancienne transaction
      final index = currentList.indexWhere(
        (t) => t.id == updatedTransaction.id,
      );

      if (index != -1) {
        // Créer une nouvelle liste avec la transaction mise à jour à l'index trouvé
        final updatedList = List<Transaction>.from(currentList);
        updatedList[index] = updatedTransaction;

        // Mettre à jour l'état
        state = AsyncValue.data(updatedList);
      } else {
        // Optionnel: Si la transaction n'est pas trouvée, vous pouvez choisir de la logguer
        // ou de déclencher un rafraîchissement complet si la liste est potentiellement obsolète.
        print(
          'Transaction non trouvée dans l\'état local pour la mise à jour: ${updatedTransaction.id}',
        );
      }
    }
  }
}

// ----------------------------------------------------
// 2. PROVIDER PRINCIPAL : (FutureProvider remplacé par StateNotifierProvider.family)
// ----------------------------------------------------

// Family pour l'accès aux recharges d'un étudiant spécifique
final userRechargesNotifierProvider =
    StateNotifierProvider.family<
      UserRechargesNotifier,
      AsyncValue<List<Transaction>>,
      String
    >((ref, etudiantId) {
      final transactionService = ref.watch(transactionServiceProvider);
      return UserRechargesNotifier(etudiantId, transactionService);
    });

// ----------------------------------------------------
// 3. ADAPTATION DES PROVIDERS D'ACTION (Création/Suppression)
// ----------------------------------------------------

// REMARQUE: Les providers d'action ci-dessous ne sont plus des FutureProvider.family,
// car leur seul but est de s'exécuter et d'appeler ensuite le Notifier.
// Le résultat du Future n'est pas utilisé directement par un `ref.watch`.

// Le Provider pour créer une recharge devient une simple fonction asynchrone dans un `Provider`
final createRechargeActionProvider = Provider((ref) {
  final transactionService = ref.watch(transactionServiceProvider);

  // Fonction qui sera appelée depuis le widget
  Future<Transaction> createRecharge({
    required String etudiantId,
    required int amount,
    required String phone,
    String description = '',
    String currency = 'CDF',
    String paymentMethod = 'mobile_money',
  }) async {
    try {
      // 1. Appeler le service API
      final transaction = await transactionService.createRecharge(
        etudiantId: etudiantId,
        amount: amount,
        phone: phone,
        description: description,
        currency: currency,
        paymentMethod: paymentMethod,
      );

      // 2. Mettre à jour l'état local IMMÉDIATEMENT via le Notifier
      // Ajouter la transaction en tête de liste pour l'UX
      ref
          .read(userRechargesNotifierProvider(etudiantId).notifier)
          .addTransaction(transaction);

      return transaction;
    } catch (e) {
      print('❌ Erreur création recharge: $e');
      rethrow;
    }
  }

  return createRecharge;
});

// Le Provider pour supprimer une recharge
final deleteRechargeActionProvider = Provider((ref) {
  final transactionService = ref.watch(transactionServiceProvider);

  Future<void> deleteRecharge({
    required String rechargeId,
    required String etudiantId,
  }) async {
    try {
      // 1. Appeler le service API
      await transactionService.deleteRecharge(rechargeId);

      // 2. Mettre à jour l'état local IMMÉDIATEMENT via le Notifier
      ref
          .read(userRechargesNotifierProvider(etudiantId).notifier)
          .removeTransaction(rechargeId);

      print('✅ Recharge supprimée avec succès: $rechargeId');
    } catch (e) {
      print('❌ Erreur suppression recharge: $e');
      rethrow;
    }
  }

  return deleteRecharge;
});

// ... (Le Provider pour effectuer le paiement d'une recharge)
final payRechargeActionProvider = Provider((ref) {
  final transactionService = ref.watch(transactionServiceProvider);

  Future<Transaction> payRecharge({
    required String rechargeId,
    required Map<String, dynamic> transactionData,
  }) async {
    try {
      // 1. Appeler le service API (qui fait le PUT)
      final transaction = await transactionService.payRecharge(
        rechargeId: rechargeId,
        transactionData: transactionData,
      );

      print('✅ Paiement effectué: $rechargeId');
      print(
        'Détails de la transaction mis à jour (incluant nouvel orderNumber): ${transaction.orderNumber}',
      );

      // 2. Récupérer l'ID de l'étudiant pour accéder au Notifier
      // Assurez-vous d'avoir l'ID de l'étudiant, soit de transactionData, soit via authProvider
      // Nous allons utiliser la méthode recommandée par Riverpod: lire le provider d'auth.
      final etudiantId = ref.read(authProvider).user!.etudiant.id;

      // 3. Mettre à jour l'état local IMMÉDIATEMENT via le Notifier
      // La 'transaction' retournée par l'API contient désormais l'orderNumber mis à jour.
      ref
          .read(userRechargesNotifierProvider(etudiantId).notifier)
          .updateTransaction(transaction); // Utilisation de la nouvelle méthode

      return transaction;
    } catch (e) {
      print('❌ Erreur paiement: $e');
      rethrow;
    }
  }

  return payRecharge;
});

// Le Provider pour vérifier le statut d'une recharge
// final checkRechargeStatusActionProvider = Provider((ref) {
//   final transactionService = ref.watch(transactionServiceProvider);

//   Future<RechargeStatus> checkStatus(String orderNumber) async {
//     try {
//       final status = await transactionService.checkRechargeStatus(orderNumber);
//       print('✅ Statut vérifié: ${status.status}');
//       return status;
//     } catch (e) {
//       print('❌ Erreur vérification: $e');
//       rethrow;
//     }
//   }

//   return checkStatus;
// });
// Le Provider pour vérifier le statut d'une recharge
final checkRechargeStatusActionProvider = Provider((ref) {
  final transactionService = ref.watch(transactionServiceProvider);

  Future<RechargeStatus> checkStatus(String orderNumber) async {
    try {
      final status = await transactionService.checkRechargeStatus(orderNumber);
      print('✅ Statut vérifié: ${status.status}');

      // Logique critique: Si la vérification indique succès, forcez la mise à jour du Notifier
      // Le backend est censé mettre à jour le statut de la transaction et créditer le compte.
      if (status.status == 'SUCCESS' ||
          status.status == 'PAID' ||
          status.status == 'completed') {
        // Adaptez le statut
        final etudiantId = ref.read(authProvider).user!.etudiant.id;
        // Rafraîchir la liste complète des transactions et le solde
        ref
            .read(userRechargesNotifierProvider(etudiantId).notifier)
            .fetchRecharges();
        // ref.invalidate(balanceProvider); // Si vous avez un provider de solde
      }

      return status;
    } catch (e) {
      print('❌ Erreur vérification: $e');
      rethrow;
    }
  }

  return checkStatus;
});
