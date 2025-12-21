import 'package:student_app/model/matiere_model.dart';
import 'package:student_app/model/student_model.dart';

class Note {
  final String id;
  final Matiere matiereId;
  final Etudiant etudiantId;
  final double cmi;
  final double examen;
  final double rattrapage;

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
      cmi: json['cmi'] as double,
      examen: json['examen'] as double,
      rattrapage: json['rattrapage'] as double,
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
