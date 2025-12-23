import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/model/recharge_model.dart';
import 'package:student_app/model/student_model.dart';
import 'package:student_app/stores/dio_provider.dart';
import 'package:student_app/stores/student_provider.dart';

class RechargeAsyncNotifier extends AsyncNotifier<List<Recharge>> {
  late final Dio _dio = ref.read(dioProvider);
  late final Etudiant currentEtudiant;

  @override
  Future<List<Recharge>> build() async {
    final etudiantState = ref.watch(etudiantProvider);

    // Éviter les appels multiples en attendant directement l'AsyncValue
    if (etudiantState.hasValue && etudiantState.value != null) {
      return _fetchRecharges(etudiantState.value!.id);
    }

    return [];
  }

  Future<List<Recharge>> _fetchRecharges(String etudiantId) async {
    try {
      final response = await _dio.get(
        '/recharge?etudiantId=$etudiantId&limit=200',
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        late final List<dynamic> data;
        if (responseData['success'] == true && responseData['data'] != null) {
          // Si la réponse est dans un format { "success": true, "data": [...] }
          data = responseData['data'] as List<dynamic>;
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] != null) {
          return Recharge.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw Exception(
            'Format de réponse inattendu: ${responseData['message'] ?? 'Erreur inconnue'}',
          );
        }
      } else {
        throw Exception('Failed to create recharge: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création de la recharge: $e');
    }
  }

  Future<Recharge> _makingPayement({
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
        if (responseData['success'] == true && responseData['data'] != null) {
          return Recharge.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw Exception(
            'Format de réponse inattendu: ${responseData['message'] ?? 'Erreur inconnue'}',
          );
        }
      } else {
        throw Exception('Failed to update recharge: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la recharge: $e');
    }
  }

  Future<bool> _deleteRecharge(String rechargeId) async {
    try {
      final response = await _dio.delete('/recharges/$rechargeId?force=true');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete recharge: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la recharge: $e');
    }
  }

  Future<dynamic> _checkingRecharge({required String orderNumber}) async {
    try {
      final response = await _dio.get('/recharge/$orderNumber/status');

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

  // Helper pour mettre à jour le statut d'une recharge localement
  void _updateRechargeStatusLocally(String orderNumber, String newStatus) {
    state.whenData((currentRecharges) {
      final updatedRecharges = currentRecharges.map((recharge) {
        if (recharge.orderNumber != null &&
            recharge.orderNumber == orderNumber) {
          return recharge.copyWith(
            status: newStatus,
            updatedAt: DateTime.now(),
          );
        }
        return recharge;
      }).toList();
      state = AsyncValue.data(updatedRecharges);
    });
  }

  // Méthode publique pour vérifier une recharge
  Future<Map<String, dynamic>> checkRecharge(String orderNumber) async {
    try {
      final response = await _checkingRecharge(orderNumber: orderNumber);

      print(response['data'].toString());
      // Vérifier si la réponse contient newBalance pour mettre à jour le solde
      if (response is Map<String, dynamic> &&
          response['success'] == true &&
          response['data'] != null &&
          response['data']['newBalance'] != null) {
        // Mettre à jour le solde utilisateur avec la nouvelle approche
        final etudiantNotifier = ref.read(etudiantProvider.notifier);
        final newBalance = (response['data']['newBalance'] as num).toDouble();

        // Essayer d'abord de récupérer les données fraîches du serveur
        try {
          await etudiantNotifier.refreshSolde();
        } catch (e) {
          // En cas d'échec, utiliser le newBalance fourni localement
          await etudiantNotifier.updateSoldeLocally(newBalance);
        }

        // Mettre à jour le statut de la recharge localement
        _updateRechargeStatusLocally(orderNumber, 'completed');
      }
      // Vérifier si le statut a changé même si success=false
      else if (response is Map<String, dynamic> &&
          response['data'] != null &&
          response['data']['status'] != null) {
        final newStatus = response['data']['status'] as String;
        _updateRechargeStatusLocally(orderNumber, newStatus);
      }

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de vérification: $e',
        'data': null,
      };
    }
  }

  // Méthode publique pour refetch les recharges
  Future<void> refetchRecharges() async {
    final etudiantState = ref.read(etudiantProvider);

    await etudiantState.when(
      data: (etudiant) async {
        if (etudiant != null) {
          state = const AsyncValue.loading();
          try {
            final recharges = await _fetchRecharges(etudiant.id);
            state = AsyncValue.data(recharges);
          } catch (e, st) {
            state = AsyncValue.error(e, st);
          }
        }
      },
      loading: () async {},
      error: (_, __) async {},
    );
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

  Future<void> createPaymement({
    required String currency,
    required String phone,
    required double amount,
    required String description,
    required String id,
  }) async {
    // Sauvegarder l'état actuel avant le loading
    final currentState = state;
    state = const AsyncValue.loading();

    try {
      final updatedRecharge = await _makingPayement(
        currency: currency,
        phone: phone,
        amount: amount,
        description: description,
        id: id,
      );

      print("Recharge mise à jour: ${updatedRecharge.toJson()}");

      // Mettre à jour localement avec les données actuelles ou vides si pas de données
      final currentRecharges = currentState.hasValue
          ? currentState.value!
          : <Recharge>[];
      final updatedRecharges = currentRecharges.map((recharge) {
        if (recharge.id == id) {
          return updatedRecharge;
        }
        return recharge;
      }).toList();

      state = AsyncValue.data(updatedRecharges);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow; // Relancer l'exception pour que le UI puisse la capturer
    }
  }

  // Mettre à jour le statut d'une recharge via API
  Future<bool> updateRechargeStatus({
    required String orderNumber,
    required String transactionId,
    required String status,
  }) async {
    try {
      final response = await _checkingRecharge(orderNumber: orderNumber);

      final responseData = response as Map<String, dynamic>;

      if (responseData['success'] == true) {
        final data = responseData['data'] as Map<String, dynamic>;
        final updatedOrderNumber = data['orderNumber'] as String;
        final newStatus = data['status'] as String;
        final updatedAt = DateTime.parse(data['updatedAt'] as String);

        // Mettre à jour la recharge localement
        state.whenData((currentRecharges) {
          final updatedRecharges = currentRecharges.map((recharge) {
            if (recharge.orderNumber != null &&
                recharge.orderNumber == updatedOrderNumber) {
              final updatedRecharge = recharge.copyWith(
                status: newStatus,
                updatedAt: updatedAt,
              );

              // Si le statut est 'completed', noter que le serveur gère le solde
              // Le solde sera synchronisé lors de la prochaine connexion

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
