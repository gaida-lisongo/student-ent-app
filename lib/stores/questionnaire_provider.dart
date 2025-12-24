import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/model/questionnaire_model.dart';
import 'package:student_app/stores/dio_provider.dart';

class QuestionnaireNotifier extends AsyncNotifier<Questionnaire?> {
  late Dio _dio;
  final String activityId;

  QuestionnaireNotifier(this.activityId);

  @override
  FutureOr<Questionnaire?> build() async {
    _dio = ref.read(dioProvider);
    return _fetchQuestionnaire(activityId);
  }

  Future<Questionnaire?> _fetchQuestionnaire(String id) async {
    try {
      final response = await _dio.get('/questions', queryParameters: {'activityId': id});
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Questionnaire.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      throw e;
    }
  }

  Future<Map<String, dynamic>?> submitResolution({
    required String studentId,
    required double score,
  }) async {
    try {
      final response = await _dio.patch(
        '/charges/activites',
        data: {
          'activityId': activityId,
          'studentId': studentId,
          'score': score,
        },
      );

      if (response.data['success'] == true) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error submitting resolution: $e');
      return null;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchQuestionnaire(activityId));
  }
}

final questionnaireProvider = AsyncNotifierProvider.family<QuestionnaireNotifier, Questionnaire?, String>(
  (arg) => QuestionnaireNotifier(arg),
);
