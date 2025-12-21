import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/model/recharge_model.dart';
import 'package:student_app/model/student_model.dart';
import 'package:student_app/stores/dio_prodiver.dart';
import 'package:student_app/stores/student_provider.dart';

class RechargeAsyncNotifier extends AsyncNotifier<List<Recharge>> {
  late final Dio _dio;
  late final Etudiant currentEtudiant;

  @override
  Future<List<Recharge>> build() async {
    _dio = ref.read(dioProvider);
    final etudiantState = ref.watch(etudiantProvider);

    return etudiantState.when(
      data: (etudiant) async {
        if (etudiant == null) return [];
        return _fetchRecharges(etudiant.id);
      },
      loading: () => [],
      error: (_, __) => [],
    );
  }

  Future<List<Recharge>> _fetchRecharges(String etudiantId) async {
    try {
      final response = await _dio.get(
        '/recharge?etudiantId=$etudiantId&limit=200',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Gérer différents formats de réponse
        List<dynamic> data;
        if (responseData is Map<String, dynamic>) {
          // Si la réponse est dans un format { "data": [...] }
          data = responseData['data'] as List<dynamic>? ?? [];
        } else if (responseData is List<dynamic>) {
          // Si la réponse est directement une liste
          data = responseData;
        } else {
          throw Exception('Format de réponse inattendu');
        }

        final sortedRecharges =
            data
                .map((json) => Recharge.fromJson(json as Map<String, dynamic>))
                .toList()
              ..sort((a, b) {
                // Gestion des dates nulles pour le tri
                if (a.createdAt == null && b.createdAt == null) return 0;
                if (a.createdAt == null) return 1;
                if (b.createdAt == null) return -1;
                return b.createdAt!.compareTo(a.createdAt!);
              });

        return sortedRecharges;
      } else {
        throw Exception('Failed to load recharges: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des recharges: $e');
    }
  }

  Future<Recharge> _createRecharge({
    required String etudiantId,
    required double amount,
    required String phone,
    required String currency,
    required String description,
  }) async {
    try {
      final response = await _dio.post(
        '/recharge',
        data: {
          'etudiantId': etudiantId,
          'amount': amount,
          'phone': phone,
          'currency': currency,
          'description': description,
        },
      );

      if (response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        return Recharge.fromJson(responseData);
      } else {
        throw Exception('Failed to create recharge: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création de la recharge: $e');
    }
  }

  Future<Recharge> _updateRecharge({
    required String currency,
    required String phone,
    required double amount,
    required String description,
    required String id,
  }) async {
    try {
      final response = await _dio.put(
        '/recharge?rechargeId=$id',
        data: {
          'amount': amount,
          'phone': phone,
          'currency': currency,
          'description': description,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        return Recharge.fromJson(responseData);
      } else {
        throw Exception('Failed to update recharge: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la recharge: $e');
    }
  }

  Future<bool> _deleteRecharge(String rechargeId) async {
    try {
      final response = await _dio.delete('/recharges/$rechargeId');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete recharge: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la recharge: $e');
    }
  }

  Future<dynamic> _checkingRecharge({
    required String status,
    required String transactionId,
    required String orderNumber,
  }) async {
    try {
      final response = await _dio.post(
        '/recharge/$orderNumber/status',
        data: {'status': status, 'transactionId': transactionId},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData;
      } else {
        throw Exception('Failed to check recharge: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la vérification de la recharge: $e');
    }
  }

  // Méthode publique pour recharger les données
  Future<void> refreshRecharges() async {
    final etudiantState = ref.read(etudiantProvider);

    etudiantState.whenData((etudiant) async {
      if (etudiant == null) return;

      state = const AsyncValue.loading();
      try {
        final recharges = await _fetchRecharges(etudiant.id);
        state = AsyncValue.data(recharges);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    });
  }

  // Créer une nouvelle recharge via API et l'ajouter à la liste
  Future<bool> addRecharge({
    required double amount,
    required String phone,
    required String currency,
    required String description,
  }) async {
    final etudiantState = ref.read(etudiantProvider);

    return await etudiantState.when(
      data: (etudiant) async {
        if (etudiant == null) return false;

        try {
          final newRecharge = await _createRecharge(
            etudiantId: etudiant.id,
            amount: amount,
            phone: phone,
            currency: currency,
            description: description,
          );

          // Ajouter à la liste locale
          state.whenData((currentRecharges) {
            final updatedRecharges = [newRecharge, ...currentRecharges]
              ..sort((a, b) {
                if (a.createdAt == null && b.createdAt == null) return 0;
                if (a.createdAt == null) return 1;
                if (b.createdAt == null) return -1;
                return b.createdAt!.compareTo(a.createdAt!);
              });
            state = AsyncValue.data(updatedRecharges);
          });

          return true;
        } catch (e) {
          return false;
        }
      },
      loading: () => false,
      error: (_, __) => false,
    );
  }

  // Mettre à jour le statut d'une recharge via API
  Future<bool> updateRechargeStatus({
    required String orderNumber,
    required String transactionId,
    required String status,
  }) async {
    try {
      final response = await _checkingRecharge(
        status: status,
        transactionId: transactionId,
        orderNumber: orderNumber,
      );

      final responseData = response as Map<String, dynamic>;

      if (responseData['success'] == true) {
        final data = responseData['data'] as Map<String, dynamic>;
        final updatedOrderNumber = data['orderNumber'] as String;
        final newStatus = data['status'] as String;
        final updatedAt = DateTime.parse(data['updatedAt'] as String);

        // Mettre à jour la recharge localement
        state.whenData((currentRecharges) {
          final updatedRecharges = currentRecharges.map((recharge) {
            if (recharge.orderNumber == updatedOrderNumber) {
              final updatedRecharge = recharge.copyWith(
                status: newStatus,
                updatedAt: updatedAt,
              );

              // Si le statut est 'completed', augmenter le solde de l'utilisateur
              if (newStatus == 'completed') {
                _updateUserBalance(recharge.amount);
              }

              return updatedRecharge;
            }
            return recharge;
          }).toList();
          state = AsyncValue.data(updatedRecharges);
        });

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Mettre à jour le solde de l'utilisateur
  void _updateUserBalance(double amount) {
    final etudiantNotifier = ref.read(etudiantProvider.notifier);
    final currentEtudiant = ref.read(etudiantProvider).value;

    if (currentEtudiant != null) {
      final updatedEtudiant = currentEtudiant.copyWith(
        solde: currentEtudiant.solde + amount,
      );
      etudiantNotifier.setEtudiant(updatedEtudiant);
    }
  }

  // Mettre à jour une recharge existante
  Future<bool> updateRecharge({
    required String id,
    required double amount,
    required String phone,
    required String currency,
    required String description,
  }) async {
    try {
      final updatedRecharge = await _updateRecharge(
        id: id,
        amount: amount,
        phone: phone,
        currency: currency,
        description: description,
      );

      // Mettre à jour localement
      state.whenData((currentRecharges) {
        final updatedRecharges = currentRecharges.map((recharge) {
          if (recharge.id == id) {
            return updatedRecharge;
          }
          return recharge;
        }).toList();
        state = AsyncValue.data(updatedRecharges);
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // Supprimer une recharge
  Future<bool> deleteRecharge(String rechargeId) async {
    try {
      final success = await _deleteRecharge(rechargeId);

      if (success) {
        // Supprimer localement
        state.whenData((currentRecharges) {
          final updatedRecharges = currentRecharges
              .where((recharge) => recharge.id != rechargeId)
              .toList();
          state = AsyncValue.data(updatedRecharges);
        });
      }

      return success;
    } catch (e) {
      return false;
    }
  }
}

final rechargeProvider =
    AsyncNotifierProvider<RechargeAsyncNotifier, List<Recharge>>(
      () => RechargeAsyncNotifier(),
    );
