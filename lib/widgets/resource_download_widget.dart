import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/stores/settings_provider.dart';
import 'package:student_app/stores/resource_download_provider.dart';

class ResourceDownloadWidget extends ConsumerWidget {
  final String url;
  final String? mimeType;
  final String? title;
  final String? description;
  final VoidCallback? onDownloadStart;
  final VoidCallback? onDownloadComplete;

  const ResourceDownloadWidget({
    super.key,
    required this.url,
    this.mimeType,
    this.title,
    this.description,
    this.onDownloadStart,
    this.onDownloadComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadState = ref.watch(resourceDownloadProvider);
    final hasUrl = url.isNotEmpty;

    if (!hasUrl) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text("Aucun fichier associé à cette ressource."),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: downloadState.isDownloading
            ? null
            : () => _downloadResource(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (downloadState.isDownloading) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Téléchargement: ${(downloadState.progress * 100).toInt()}%',
                ),
                const SizedBox(height: 16),
              ] else ...[
                Icon(_getFileIcon(mimeType), size: 48, color: Colors.blue[400]),
                const SizedBox(height: 16),
              ],
              Text(
                title ?? _getFileName(url),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 8),
              if (description != null) ...[
                Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                mimeType ?? "Fichier",
                style: TextStyle(color: Colors.grey[600]),
              ),
              if (downloadState.isDownloading) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(value: downloadState.progress),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadResource(BuildContext context, WidgetRef ref) async {
    onDownloadStart?.call();

    final baseUrl = ref.read(assetBaseUrlProvider);
    final downloadNotifier = ref.read(resourceDownloadProvider.notifier);

    await downloadNotifier.downloadResource(
      url: url,
      baseUrl: baseUrl,
      mimeType: mimeType,
      context: context,
    );

    // Vérifier s'il y a eu une erreur
    final downloadState = ref.read(resourceDownloadProvider);
    if (downloadState.error != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de téléchargement: ${downloadState.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      onDownloadComplete?.call();
    }
  }

  String _getFileName(String url) {
    if (url.isEmpty) return "Document";
    final parts = url.split('/');
    if (parts.isNotEmpty) {
      String fileName = parts.last;

      // Nettoyer le nom de fichier si il contient un UUID au début
      final uuidPattern = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}-',
      );
      if (uuidPattern.hasMatch(fileName)) {
        fileName = fileName.replaceFirst(uuidPattern, '');
      }

      // Décoder l'URL si nécessaire
      try {
        fileName = Uri.decodeComponent(fileName);
      } catch (e) {
        // Si le décodage échoue, garder le nom original
      }

      return fileName.isEmpty ? "Document" : fileName;
    }
    return "Document";
  }

  IconData _getFileIcon(String? mimeType) {
    if (mimeType == null) return Icons.insert_drive_file;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf;
    if (mimeType.contains('image')) return Icons.image;
    if (mimeType.contains('word')) return Icons.description;
    if (mimeType.contains('excel')) return Icons.grid_on;
    if (mimeType.contains('powerpoint')) return Icons.slideshow;
    if (mimeType.contains('video')) return Icons.video_file;
    if (mimeType.contains('audio')) return Icons.audio_file;
    if (mimeType.contains('text')) return Icons.text_snippet;
    return Icons.insert_drive_file;
  }
}
