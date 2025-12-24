import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/factories/questionnaire_factory.dart';
import 'package:student_app/model/activity_model.dart';
import 'package:student_app/stores/questionnaire_provider.dart';
import 'package:student_app/stores/student_provider.dart';

class ActivityScreen extends ConsumerWidget {
  final Activity activity;

  const ActivityScreen({super.key, required this.activity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the questionnaire provider for this activity
    final questionnaireAsync = ref.watch(questionnaireProvider(activity.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(activity.title),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact Info Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.indigo.withOpacity(0.3)),
                  ),
                  child: Text(
                    activity.type.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.star, color: Colors.orange, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${activity.maximumScore} pts max',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Description (Collapsible or just small)
            if (activity.description.isNotEmpty) ...[
              Text(
                activity.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 20),
            ],

            const Divider(),
            const SizedBox(height: 10),

            // Questionnaire Loading/Display Area
            questionnaireAsync.when(
              data: (questionnaire) {
                if (questionnaire == null) {
                  return Center(
                    child: Column(
                      children: [
                         Icon(Icons.access_time, size: 64, color: Colors.grey[300]),
                         const SizedBox(height: 16),
                         Text(
                           'Aucun contenu disponible pour le moment.',
                           textAlign: TextAlign.center,
                           style: TextStyle(color: Colors.grey[500]),
                         ),
                      ],
                    ),
                  );
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Questionnaire', 
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    QuestionnaireFactory.createWidget(
                      questionnaire: questionnaire,
                      onSubmit: (score) async {
                        final student = ref.read(etudiantProvider).value;
                        if (student == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Erreur: Aucun étudiant connecté')),
                          );
                          return null;
                        }

                        final response = await ref
                            .read(questionnaireProvider(activity.id).notifier)
                            .submitResolution(
                              studentId: student.id,
                              score: score,
                            );
                        
                        if (response != null && response['success'] == true) {
                          // Success - response will be handled by the widget
                        } else {
                           throw Exception("Échec de la soumission au serveur");
                        }
                        
                        return response;
                      },
                    ),
                  ],
                );
              },
              error: (err, stack) => Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 8),
                    Text('Erreur: $err', textAlign: TextAlign.center),
                    ElevatedButton(
                      onPressed: () => ref.refresh(questionnaireProvider(activity.id)),
                      child: const Text('Réessayer'),
                    )
                  ],
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}
