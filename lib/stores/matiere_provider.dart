import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:student_app/model/charge_model.dart';
import 'package:student_app/stores/dio_provider.dart';

class MatiereProvider extends StateNotifier<Charge> {
  MatiereProvider(this.ref) : super(Charge.empty());
  final Ref ref;
  late final Dio _dio = ref.watch(dioProvider);

  void setMatiere(Charge matiere) {
    state = matiere;
  }

  void clearMatiere() {
    state = Charge.empty();
  }

  Future<void> fetchRecharge(String matiereId, String anneeId) async {
    try {
      print('🔄 Fetching charge pour cours: $matiereId, année: $anneeId');

      final response = await _dio.get(
        '/charges?coursId=$matiereId&anneeId=$anneeId',
      );

      print('📥 Réponse reçue - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        print('📄 Type de données: ${responseData.runtimeType}');
        print('📄 Contenu: $responseData');

        if (responseData is Map<String, dynamic>) {
          // Vérifier si la réponse contient le champ 'data' et 'success'
          if (responseData['success'] == true && responseData['data'] != null) {
            print('✅ Format de réponse valide avec success=true');

            final chargeData = responseData['data'];
            print('📊 Données de charge: $chargeData');

            if (chargeData is Map<String, dynamic>) {
              final charge = Charge.fromJson(chargeData);
              state = charge;
              print('✅ Charge chargée avec succès: ${charge.id}');
            } else {
              throw Exception(
                'Les données de charge ne sont pas au bon format: ${chargeData.runtimeType}',
              );
            }
          } else {
            throw Exception(
              'Format de réponse invalide - success: ${responseData['success']}, data: ${responseData['data']}',
            );
          }
        } else {
          // Si la réponse n'est pas encapsulée dans un objet avec 'success'
          print('ℹ️ Réponse directe sans wrapper success');
          if (responseData is Map<String, dynamic>) {
            final charge = Charge.fromJson(
              responseData as Map<String, dynamic>,
            );
            state = charge;
            print('✅ Charge chargée directement avec succès: ${charge.id}');
          } else {
            throw Exception(
              'Format de réponse inattendu: ${responseData.runtimeType}',
            );
          }
        }
      } else {
        throw Exception(
          'Erreur HTTP lors du chargement de la charge: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      print('❌ Erreur fetchRecharge: $e');
      print('📍 StackTrace: $stackTrace');
      rethrow;
    }
  }

  // Vérifier si l'étudiant est déjà présent
  Future<Map<String, dynamic>> checkPresence(
    String seanceId,
    String studentId,
  ) async {
    try {
      final response = await _dio.get(
        '/seances/$seanceId',
        queryParameters: {'studentId': studentId},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          'Erreur lors de la vérification de présence: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Erreur checkPresence: $e');
      rethrow;
    }
  }

  // Marquer la présence
  Future<Map<String, dynamic>> markPresence({
    required String seanceId,
    required String studentId,
    required String locationQr,
    required String locationStudent,
  }) async {
    try {
      final response = await _dio.post(
        '/seances/$seanceId',
        data: {
          'studentId': studentId,
          'locationQr': locationQr,
          'locationStudent': locationStudent,
        },
      );

      if (response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;

        // Rafraîchir les données de la matière pour mettre à jour la liste des présences
        // Note: Cela suppose que nous avons accès à matiereId et anneeId.
        // Si non, on pourrait devoir les stocker dans le state ou les passer en paramètre.
        // Pour l'instant, on retourne juste le succès.

        return responseData;
      } else {
        throw Exception(
          'Erreur lors du marquage de la présence: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Erreur markPresence: $e');
      rethrow;
    }
  }
}

final matiereProvider = StateNotifierProvider<MatiereProvider, Charge>((ref) {
  return MatiereProvider(ref);
});
