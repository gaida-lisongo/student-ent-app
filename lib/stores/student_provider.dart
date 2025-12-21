import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:student_app/model/student_model.dart';

class EtudiantNotifier extends AsyncNotifier<Etudiant?> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<Etudiant?> build() async {
    try {
      final jsonString = await _storage.read(key: 'etudiant');
      if (jsonString == null) return null;

      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      final etudiant = Etudiant.fromJson(jsonMap);
      return etudiant;
    } catch (e, st) {
      throw Exception('Erreur lors du chargement de l’étudiant: $e');
    }
  }
}

final etudiantProvider = AsyncNotifierProvider<EtudiantNotifier, Etudiant?>(
  () => EtudiantNotifier(),
);
