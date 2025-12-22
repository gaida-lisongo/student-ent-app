import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:student_app/model/charge_model.dart';
import 'package:student_app/stores/dio_prodiver.dart';

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
      final response = await _dio.get(
        '/charges?coursId=$matiereId&anneeId=$anneeId',
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        print('Charge data fetched: $responseData');

        // Vérifier si la réponse contient le champ 'data' et 'success'
        if (responseData['success'] == true && responseData['data'] != null) {
          final charge = Charge.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
          state = charge;
        } else {
          throw Exception('Format de réponse invalide');
        }
      } else {
        throw Exception(
          'Erreur lors du chargement de la matière: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Erreur fetchRecharge: $e');
      rethrow;
    }
  }
}

final matiereProvider = StateNotifierProvider<MatiereProvider, Charge>((ref) {
  return MatiereProvider(ref);
});
