import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
    // Ne pas mettre en loading pour les mises à jour, seulement sauvegarder
    try {
      final jsonString = jsonEncode(etudiant.toJson());
      await _storage.write(key: 'etudiant', value: jsonString);

      // Important : créer un nouvel AsyncValue pour forcer la notification
      // Utiliser AsyncValue.guard ou créer explicitement un nouveau AsyncValue
      final previousState = state;
      state = const AsyncValue.loading();
      await Future.delayed(
        Duration.zero,
      ); // Petit délai pour forcer le changement
      state = AsyncValue.data(etudiant);
    } catch (e, st) {
      // En cas d'erreur, garder l'état actuel plutôt que de tout casser
      if (!state.hasValue) {
        state = AsyncValue.error(e, st);
      }
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

    // Ne pas mettre en loading pour éviter que l'UI disparaisse
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
          final etudiantData = result['etudiant'] as Map<String, dynamic>;

          try {
            final updatedEtudiant = Etudiant.fromJson(etudiantData);

            await setEtudiant(updatedEtudiant);

            return true;
          } catch (parseError, parseStack) {
            // Ne pas mettre l'état en erreur, garder l'état actuel
            return false;
          }
        } else {
          final errorMsg =
              result['error'] ??
              result['message'] ??
              'Erreur lors de la mise à jour du profil';
          // Ne pas mettre l'état en erreur, juste retourner false
          return false;
        }
      } else {
        // Ne pas mettre l'état en erreur, juste retourner false
        return false;
      }
    } catch (e, st) {
      // Ne pas mettre l'état en erreur pour éviter de casser l'UI
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

  // Méthode pour uploader une photo de profil (compatible mobile et web)
  Future<bool> uploadProfilePhoto(String imagePath) async {
    final currentEtudiant = state.value;
    if (currentEtudiant?.id == null) {
      state = AsyncValue.error('Aucun étudiant connecté', StackTrace.current);
      return false;
    }

    try {
      MultipartFile multipartFile;

      if (kIsWeb) {
        // Pour le web, on ne peut pas utiliser dart:io
        // Il faudrait passer directement les bytes depuis le picker
        throw Exception(
          'Upload de photo non supporté sur le web pour le moment',
        );
      } else {
        // Pour mobile/desktop
        final file = File(imagePath);
        final bytes = await file.readAsBytes();

        multipartFile = MultipartFile.fromBytes(
          bytes,
          filename: 'profile_photo.jpg',
        );
      }

      final formData = FormData.fromMap({'photo': multipartFile});

      final response = await _dio.put(
        '/etudiant/${currentEtudiant!.id}/photo',
        data: formData,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Récupérer les données mises à jour
        final updatedEtudiant = Etudiant.fromJson(response.data['etudiant']);
        await setEtudiant(updatedEtudiant);
        return true;
      }
      return false;
    } catch (e, st) {
      print('Erreur upload photo: $e');
      state = AsyncValue.error('Erreur lors de l\'upload de la photo: $e', st);
      return false;
    }
  }

  // Méthode alternative qui accepte directement les bytes (compatible web et mobile)
  Future<bool> uploadProfilePhotoFromBytes(
    Uint8List bytes,
    String filename,
  ) async {
    final currentEtudiant = state.value;
    if (currentEtudiant?.id == null) {
      state = AsyncValue.error('Aucun étudiant connecté', StackTrace.current);
      return false;
    }

    try {
      final formData = FormData.fromMap({
        'photo': MultipartFile.fromBytes(bytes, filename: filename),
      });

      final response = await _dio.put(
        '/etudiant/${currentEtudiant!.id}/photo',
        data: formData,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Récupérer les données mises à jour
        final updatedEtudiant = Etudiant.fromJson(response.data['etudiant']);
        await setEtudiant(updatedEtudiant);
        return true;
      }
      return false;
    } catch (e, st) {
      print('Erreur upload photo from bytes: $e');
      state = AsyncValue.error('Erreur lors de l\'upload de la photo: $e', st);
      return false;
    }
  }

  // Méthode pour supprimer la photo de profil
  Future<bool> deleteProfilePhoto() async {
    final currentEtudiant = state.value;
    if (currentEtudiant?.id == null) {
      state = AsyncValue.error('Aucun étudiant connecté', StackTrace.current);
      return false;
    }

    try {
      final response = await _dio.delete(
        '/etudiant/${currentEtudiant!.id}/photo',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Récupérer les données mises à jour
        final updatedEtudiant = Etudiant.fromJson(response.data['etudiant']);
        await setEtudiant(updatedEtudiant);
        return true;
      }
      return false;
    } catch (e, st) {
      state = AsyncValue.error(
        'Erreur lors de la suppression de la photo: $e',
        st,
      );
      return false;
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
