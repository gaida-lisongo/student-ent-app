import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/model/questionnaire_model.dart';
import 'package:student_app/stores/settings_provider.dart';
import 'package:student_app/stores/questionnaire_provider.dart';
import 'package:student_app/stores/student_provider.dart';

// Very similar to ProjetWidget as the user requirement is also "submit a resolution file"
class TPWidget extends ConsumerStatefulWidget {
  final TPData data;
  final String activityId;
  final Future<Map<String, dynamic>?> Function(double score) onSubmit;

  const TPWidget({
    super.key, 
    required this.data, 
    required this.activityId,
    required this.onSubmit
  });

  @override
  ConsumerState<TPWidget> createState() => _TPWidgetState();
}

class _TPWidgetState extends ConsumerState<TPWidget> {
  PlatformFile? _selectedFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un fichier à soumettre.')),
      );
      return;
    }

    final student = ref.read(etudiantProvider).value;
    if (student == null) return;

    // Show loading dialog or state
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await widget.onSubmit(0.0);
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("TP soumis avec succès !"), backgroundColor: Colors.green),
          );
      }
    } catch (e) {
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erreur lors de la soumission."), backgroundColor: Colors.red),
          );
      }
    } finally {
      if (mounted) Navigator.pop(context); // Close loading
    }
  }

  @override
  Widget build(BuildContext context) {
    // For TPs, we often have a list of smaller tasks or one big task.
    // The model has "questionnaires" list.
    final baseUrl = ref.watch(assetBaseUrlProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Travaux Pratiques",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        if (widget.data.questionnaires.isEmpty) 
          const Text("Aucun énoncé trouvé pour ce TP."),

        ...widget.data.questionnaires.map((tp) => Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tp.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(tp.description),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Chip(
                      label: Text("${tp.points} pts"),
                      backgroundColor: Colors.orange[50], 
                      labelStyle: TextStyle(color: Colors.orange[800]),
                    ),
                    const SizedBox(width: 8),
                    if (tp.attachedFile != null)
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            // TODO: Download logic
                           ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Téléchargement de ${tp.attachedFile!.name} (TODO)')),
                            );
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.attachment, size: 20, color: Colors.blue),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  tp.attachedFile!.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        )).toList(),
        
        const SizedBox(height: 24),

         // Submission Zone
        const Text(
          "Votre Compte-rendu",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (_selectedFile != null) ...[
                const Icon(Icons.description, size: 48, color: Colors.green),
                const SizedBox(height: 8),
                Text(
                  _selectedFile!.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '${(_selectedFile!.size / 1024).toStringAsFixed(2)} KB',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.change_circle),
                  label: const Text('Changer de fichier'),
                ),
              ] else ...[
                const Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                const Text("Sélectionnez votre fichier de réponse"),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Parcourir'),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),
        
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Soumettre le TP',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 40),

      ],
    );
  }
}
