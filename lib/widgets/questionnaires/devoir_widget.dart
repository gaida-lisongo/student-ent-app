import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/model/questionnaire_model.dart';
import 'package:student_app/stores/settings_provider.dart';
import 'package:student_app/stores/questionnaire_provider.dart';
import 'package:student_app/stores/student_provider.dart';

class DevoirWidget extends ConsumerWidget {
  final DevoirData data;
  final String activityId;
  final Future<Map<String, dynamic>?> Function(double score) onSubmit;

  const DevoirWidget({
    super.key, 
    required this.data, 
    required this.activityId,
    required this.onSubmit
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseUrl = ref.watch(assetBaseUrlProvider);

    print('devoir: ${data.toJson()}');  
    final hasUrl = data.url != null && data.url!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.class_, size: 64, color: Colors.indigo),
          const SizedBox(height: 24),
          const Text(
            "Ressource de Devoir",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            "Voici le support pour votre devoir. Consultez-le pour compléter l'activité.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          
          if (hasUrl)
             Card(
              elevation: 4,
              child: InkWell(
                onTap: () {
                   // TODO: Implement Download/Open Logic
                   ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ouverture du fichier... (TODO)')),
                    );
                },
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        _getFileIcon(data.typeFile),
                        size: 48,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getFileName(data.url!),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(data.typeFile ?? "Fichier inconnu", style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
            )
          else
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text("Aucun fichier associé à ce devoir."),
              ),
            ),
            
          const SizedBox(height: 40),
          // Usually a "Devoir" might just be "Consulted" or marking as read? 
          // Or user might need to submit something elsewhere? 
          // JSON implies just retrieval: "l'étudiant n'a qu'à recuérer la ressource"
          ElevatedButton.icon(
            onPressed: () async {
              try {
                await onSubmit(0.0);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Activitié marquée comme vue !"), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                 if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Erreur lors de la soumission."), backgroundColor: Colors.red),
                  );
                }
              }
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text("Marquer comme vu"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          )
        ],
      ),
    );
  }

  String _getFileName(String url) {
    if (url.isEmpty) return "Document";
    final parts = url.split('/');
    if (parts.isNotEmpty) {
      // Decode URI component if needed, and maybe strip UUID prefix if present logic exists
      return parts.last;
    }
    return "Document";
  }

  IconData _getFileIcon(String? mimeType) {
    if (mimeType == null) return Icons.insert_drive_file;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf;
    if (mimeType.contains('image')) return Icons.image;
    if (mimeType.contains('word')) return Icons.description;
    return Icons.insert_drive_file;
  }
}
