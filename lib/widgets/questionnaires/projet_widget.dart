import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/model/questionnaire_model.dart';
import 'package:student_app/stores/settings_provider.dart';
import 'package:student_app/stores/questionnaire_provider.dart';
import 'package:student_app/stores/student_provider.dart';

class ProjetWidget extends ConsumerStatefulWidget {
  final ProjetData data;
  final String activityId;
  final Future<Map<String, dynamic>?> Function(double score) onSubmit;

  const ProjetWidget({
    super.key, 
    required this.data, 
    required this.activityId,
    required this.onSubmit
  });

  @override
  ConsumerState<ProjetWidget> createState() => _ProjetWidgetState();
}

class _ProjetWidgetState extends ConsumerState<ProjetWidget> {
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

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await widget.onSubmit(0.0);
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Projet soumis avec succès !"), backgroundColor: Colors.green),
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
    final baseUrl = ref.watch(assetBaseUrlProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Context
        if (widget.data.contexte.isNotEmpty) ...[
          const Text(
            "Contexte",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.data.contexte,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
        ],

        // Problematiques
        if (widget.data.problematiques.isNotEmpty) ...[
          const Text(
            "Problématiques & Ressources",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...widget.data.problematiques.map((prob) => Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prob.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(prob.description),
                  const SizedBox(height: 12),
                  if (prob.attachedFile != null)
                    InkWell(
                      onTap: () {
                        // TODO: Implement Download/Open Logic
                        // url: "$baseUrl${prob.attachedFile!.url}"
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Téléchargement de ${prob.attachedFile!.name} (TODO)')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[100]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.attach_file, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                prob.attachedFile!.name,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.download, color: Colors.blue),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )).toList(),
          const SizedBox(height: 24),
        ],

        // Submission Zone
        const Text(
          "Votre Résolution",
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
              'Soumettre le Projet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
