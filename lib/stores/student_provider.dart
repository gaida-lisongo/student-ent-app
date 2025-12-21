import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:student_app/model/student_model.dart';
import 'package:student_app/stores/dio_prodiver.dart';

class EtudiantNotifier extends AsyncNotifier<Etudiant?> {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<Etudiant?> build() async {
    try {
      _dio = ref.read(dioProvider);
      final jsonString = await _storage.read(key: 'etudiant');
      if (jsonString == null) return null;

      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      final etudiant = Etudiant.fromJson(jsonMap);

      return etudiant;
    } catch (e) {
      throw Exception('Erreur lors du chargement de l’étudiant: $e');
    }
  }

  Future<void> setEtudiant(Etudiant etudiant) async {
    state = const AsyncValue.loading();
    try {
      final jsonString = jsonEncode(etudiant.toJson());
      await _storage.write(key: 'etudiant', value: jsonString);
      print("New Etudiant Stored: $jsonString");
      state = AsyncValue.data(etudiant);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      throw Exception('Erreur lors de la sauvegarde de l\'étudiant: $e');
    }
  }

  // Fonction pour mettre à jour le profil étudiant (adaptée du NextJS)
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    final currentEtudiant = state.value;

    if (currentEtudiant?.id == null) {
      state = AsyncValue.error('Aucun étudiant connecté', StackTrace.current);
      return false;
    }

    state = const AsyncValue.loading();

    try {
      final response = await _dio.put(
        '/etudiant/${currentEtudiant!.id}/profile',
        data: profileData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final result = response.data as Map<String, dynamic>;

        if (result['success'] == true && result['etudiant'] != null) {
          // Créer l'étudiant mis à jour
          final updatedEtudiant = Etudiant.fromJson(
            result['etudiant'] as Map<String, dynamic>,
          );

          await setEtudiant(updatedEtudiant);

          return true;
        } else {
          final errorMsg =
              result['error'] ?? 'Erreur lors de la mise à jour du profil';
          state = AsyncValue.error(errorMsg, StackTrace.current);
          return false;
        }
      } else {
        state = AsyncValue.error(
          'Réponse invalide du serveur',
          StackTrace.current,
        );
        return false;
      }
    } catch (e, st) {
      state = AsyncValue.error('Erreur de connexion au serveur: $e', st);
      return false;
    }
  }

  // Méthode pour mettre à jour le solde en récupérant les données fraîches du serveur
  Future<void> refreshSolde() async {
    final currentEtudiant = state.value;
    if (currentEtudiant?.id == null) {
      return;
    }

    try {
      // Récupérer les données fraîches de l'étudiant depuis le serveur
      final response = await _dio.get('/etudiant/${currentEtudiant!.id}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final updatedEtudiant = Etudiant.fromJson(data['data']);
          await setEtudiant(updatedEtudiant);
        }
      }
    } catch (e) {
      // En cas d'erreur réseau, on garde le solde local
      print('Erreur lors de la récupération du solde: $e');
    }
  }

  // Méthode pour mettre à jour uniquement le solde localement (fallback)
  Future<void> updateSoldeLocally(double newBalance) async {
    final currentEtudiant = state.value;
    if (currentEtudiant != null) {
      final updatedEtudiant = currentEtudiant.copyWith(solde: newBalance);
      await setEtudiant(updatedEtudiant);
    }
  }

  Future<void> clearEtudiant() async {
    state = const AsyncValue.loading();
    try {
      await _storage.delete(key: 'etudiant');
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      throw Exception('Erreur lors de la suppression de l’étudiant: $e');
    }
  }
}

final etudiantProvider = AsyncNotifierProvider<EtudiantNotifier, Etudiant?>(
  () => EtudiantNotifier(),
);
