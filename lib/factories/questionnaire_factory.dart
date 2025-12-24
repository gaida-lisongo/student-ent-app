import 'package:flutter/material.dart';
import 'package:student_app/model/questionnaire_model.dart';
import 'package:student_app/widgets/questionnaires/devoir_widget.dart';
import 'package:student_app/widgets/questionnaires/tp_widget.dart';
import 'package:student_app/widgets/questionnaires/projet_widget.dart';
import 'package:student_app/widgets/questionnaires/qcm_widget.dart';

class QuestionnaireFactory {
  static Widget createWidget({
    required Questionnaire questionnaire,
    required Future<Map<String, dynamic>?> Function(double score) onSubmit,
  }) {
    // Reliable check based on actual content rather than just non-null objects
    // as backend sends empty shells for all types.

    if (questionnaire.qcm != null && questionnaire.qcm!.questions.isNotEmpty) {
      return QCMWidget(
        data: questionnaire.qcm!, 
        activityId: questionnaire.activityId,
        onSubmit: onSubmit,
      );
    } 
    
    if (questionnaire.tp != null && questionnaire.tp!.questionnaires.isNotEmpty) {
      return TPWidget(
        data: questionnaire.tp!,
        activityId: questionnaire.activityId,
        onSubmit: onSubmit,
      );
    } 
    
    if (questionnaire.projet != null && 
       (questionnaire.projet!.contexte.isNotEmpty || questionnaire.projet!.problematiques.isNotEmpty)) {
      return ProjetWidget(
        data: questionnaire.projet!,
        activityId: questionnaire.activityId,
        onSubmit: onSubmit,
      );
    } 
    
    if (questionnaire.devoir != null && questionnaire.devoir!.url != null && questionnaire.devoir!.url!.isNotEmpty) {
      return DevoirWidget(
        data: questionnaire.devoir!,
        activityId: questionnaire.activityId,
        onSubmit: onSubmit,
      );
    }
    
    // Default fallback if no specific valid data found
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          "Aucun contenu valide trouvé pour cette activité.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
