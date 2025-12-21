import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:student_app/stores/dio_prodiver.dart';

class AuthAsyncNotifier extends AsyncNotifier<String?> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final Dio _dio;

  @override
  Future<String?> build() async {
    _dio = ref.read(dioProvider);
    // Récupérer le token stocké au démarrage
    final token = await _storage.read(key: 'auth_token');
    return token;
  }

  Future<Map<String, dynamic>> login(String inscriptionId) async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get('/parcours/$inscriptionId');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final token = '${data['_id'] as String}:${data['statut'] as String}';

        // Store the token securely
        await _storage.write(key: 'auth_token', value: token);
        await _storage.write(
          key: 'etudiant',
          value: jsonEncode(data['etudiantId']),
        );
        await _storage.write(key: 'statut', value: data['statut'] as String);
        await _storage.write(
          key: 'promotion',
          value: jsonEncode(data['promotionId']),
        );
        await _storage.write(key: 'annee', value: jsonEncode(data['anneeId']));

        // Update state with the token
        state = AsyncValue.data(token);

        return data;
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      // Remove token from storage
      await _storage.delete(key: 'auth_token');

      // Update state to null (logged out)
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Vérifier si l'utilisateur est connecté
  bool get isLoggedIn {
    return state.value != null && state.value!.isNotEmpty;
  }

  // Obtenir l'ID d'inscription depuis le token
  String? get inscriptionId {
    final token = state.value;
    if (token != null && token.contains(':')) {
      return token.split(':')[0];
    }
    return null;
  }

  // Obtenir le statut depuis le token
  String? get status {
    final token = state.value;
    if (token != null && token.contains(':')) {
      return token.split(':')[1];
    }
    return null;
  }
}

final authProvider = AsyncNotifierProvider<AuthAsyncNotifier, String?>(
  () => AuthAsyncNotifier(),
);
