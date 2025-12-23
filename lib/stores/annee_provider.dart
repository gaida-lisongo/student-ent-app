import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:student_app/model/annee_model.dart';
import 'package:student_app/stores/auth_provider.dart';
import 'package:student_app/stores/dio_provider.dart';

class AnneeAsyncNotifier extends AsyncNotifier<Annee?> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late Dio _dio;
  @override
  Future<Annee?> build() async {
    // Watch auth state to force reload
    ref.watch(authProvider);

    _dio = ref.read(dioProvider);
    final jsonString = await _storage.read(key: 'annee');
    if (jsonString != null) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      final annee = Annee.fromJson(jsonMap);
      return annee;
    }

    return null;
  }

  Future<List<Annee?>> fetchAllAnnees() async {
    try {
      final response = await _dio.get('/annees');

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        final annees = data
            .map(
              (anneeJson) => Annee.fromJson(anneeJson as Map<String, dynamic>),
            )
            .toList();
        return annees;
      } else {
        throw Exception('Failed to load annees: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching annees: $e');
    }
  }

  setAnnee(Annee annee) async {
    state = AsyncValue.data(annee);
    final jsonString = jsonEncode(annee.toJson());
    await _storage.write(key: 'annee', value: jsonString);
  }
}

final anneeProvider = AsyncNotifierProvider<AnneeAsyncNotifier, Annee?>(
  AnneeAsyncNotifier.new,
);
