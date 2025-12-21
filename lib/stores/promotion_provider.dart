import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:student_app/model/promotion_model.dart';

class PromotionNotifier extends AsyncNotifier<Promotion?> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<Promotion?> build() async {
    try {
      final jsonString = await _storage.read(key: 'promotion');

      if (jsonString != null && jsonString.isNotEmpty) {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        final promotion = Promotion.fromJson(jsonMap);
        return promotion;
      }

      return null;
    } catch (e) {
      throw Exception('Erreur lors du chargement de la promotion: $e');
    }
  }

  Future<void> setPromotion(Promotion promotion) async {
    state = const AsyncValue.loading();
    try {
      final jsonString = jsonEncode(promotion.toJson());
      await _storage.write(key: 'promotion', value: jsonString);
      state = AsyncValue.data(promotion);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      throw Exception('Erreur lors de la sauvegarde de la promotion: $e');
    }
  }

  Future<void> clearPromotion() async {
    state = const AsyncValue.loading();
    try {
      await _storage.delete(key: 'promotion');
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      throw Exception('Erreur lors de la suppression de la promotion: $e');
    }
  }

  // Getter pour vérifier si une promotion est chargée
  bool get hasPromotion {
    return state.value != null;
  }

  // Getter pour obtenir le nom de la promotion
  String? get promotionName {
    return state.value?.designation;
  }

  // Getter pour obtenir l'ID de la promotion
  String? get promotionId {
    return state.value?.id;
  }
}

final promotionProvider = AsyncNotifierProvider<PromotionNotifier, Promotion?>(
  () => PromotionNotifier(),
);
