import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/stores/dio_provider.dart';
import 'package:student_app/stores/student_provider.dart';

// Modèle de réponse pour la souscription
class SubscriptionResponse {
  final bool success;
  final String? message;
  final dynamic transaction;
  final dynamic subscription;

  SubscriptionResponse({
    required this.success,
    this.message,
    this.transaction,
    this.subscription,
  });

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponse(
      success: json['success'] ?? false,
      message: json['error'] ?? json['data']?['message'],
      transaction: json['data']?['transaction'],
      subscription: json['data']?['subscription'],
    );
  }
}

class TransactionNotifier extends AsyncNotifier<void> {
  late Dio _dio;
  
  @override
  Future<void> build() async {
    _dio = ref.read(dioProvider);
    // Initial state is data(null) implicitly via build completing
  }

  Future<SubscriptionResponse> subscribeToTransaction({
    required String transactionId,
    required String studentId,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final response = await _dio.patch(
        '/transaction', // Endpoint transaction
        data: {
          'transactionId': transactionId,
          'studentId': studentId,
        },
      );

      final result = SubscriptionResponse.fromJson(response.data);

      if (result.success) {
        // Mettre à jour le solde de l'étudiant localement
        // Le backend renvoie le newSolde dans l'objet subscription
        if (result.subscription != null && result.subscription['newSolde'] != null) {
          final newSolde = (result.subscription['newSolde'] as num).toDouble();
            
            // Mise à jour via le provider étudiant
            await ref.read(etudiantProvider.notifier).updateSoldeLocally(newSolde);
        }
        
        state = const AsyncValue.data(null);
        return result;
      } else {
        state = AsyncValue.data(null); // Reset state to prevent sticking in error
        return result;
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      
      // Gérer les erreurs Dio avec réponse 400/409 qui contiennent souvent le message d'erreur
       if (e is DioException && e.response?.data != null) {
             try {
                final errorData = e.response!.data;
                 return SubscriptionResponse(
                   success: false,
                   message: errorData['error'] ?? 'Erreur lors de la transaction',
                 );
             } catch (_) {}
       }
      return SubscriptionResponse(success: false, message: e.toString());
    }
  }
}

final transactionProvider = AsyncNotifierProvider<TransactionNotifier, void>(
  () => TransactionNotifier(),
);
