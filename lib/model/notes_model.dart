import 'dart:ffi';

import 'package:student_app/model/matiere_model.dart';
import 'package:student_app/model/student_model.dart';

class Note {
  final String id;
  final Matiere matiereId;
  final Etudiant etudiantId;
  final Float cmi;
  final Float examen;
  final Float rattrapage;

  Note({
    required this.id,
    required this.matiereId,
    required this.etudiantId,
    required this.cmi,
    required this.examen,
    required this.rattrapage,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['_id'] as String,
      matiereId: json['matiereId'] as Matiere,
      etudiantId: json['etudiantId'] as Etudiant,
      cmi: json['cmi'] as Float,
      examen: json['examen'] as Float,
      rattrapage: json['rattrapage'] as Float,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'matiereId': matiereId.id,
      'etudiantId': etudiantId.id,
      'cmi': cmi,
      'examen': examen,
      'rattrapage': rattrapage,
    };
  }
}
