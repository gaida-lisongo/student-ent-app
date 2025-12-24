import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:url_launcher/url_launcher.dart';

// État du téléchargement
class DownloadState {
  final bool isDownloading;
  final double progress;
  final String? error;
  final String? downloadedFilePath;

  const DownloadState({
    this.isDownloading = false,
    this.progress = 0.0,
    this.error,
    this.downloadedFilePath,
  });

  DownloadState copyWith({
    bool? isDownloading,
    double? progress,
    String? error,
    String? downloadedFilePath,
  }) {
    return DownloadState(
      isDownloading: isDownloading ?? this.isDownloading,
      progress: progress ?? this.progress,
      error: error,
      downloadedFilePath: downloadedFilePath ?? this.downloadedFilePath,
    );
  }
}

// Provider pour la gestion du téléchargement de ressources
class ResourceDownloadNotifier extends StateNotifier<DownloadState> {
  ResourceDownloadNotifier(this.ref) : super(const DownloadState());
  final Ref ref;

  // Télécharger une ressource selon la plateforme
  Future<void> downloadResource({
    required String url,
    required String baseUrl,
    required String? mimeType,
    required BuildContext context,
  }) async {
    try {
      state = state.copyWith(isDownloading: true, error: null);

      // Pour toutes les plateformes, utiliser url_launcher
      await _downloadWithUrlLauncher(url, baseUrl, context);

      state = state.copyWith(isDownloading: false);
    } catch (e) {
      state = state.copyWith(isDownloading: false, error: e.toString());
    }
  }

  // Téléchargement avec url_launcher (compatible toutes plateformes)
  Future<void> _downloadWithUrlLauncher(
    String url,
    String baseUrl,
    BuildContext context,
  ) async {
    try {
      // Construire l'URL complète
      final fullUrl = url.startsWith('http') ? url : '$baseUrl$url';

      final uri = Uri.parse(fullUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                kIsWeb
                    ? 'Téléchargement ouvert dans le navigateur'
                    : 'Fichier ouvert avec l\'application par défaut',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Impossible d\'ouvrir l\'URL: $fullUrl');
      }
    } catch (e) {
      print('❌ Erreur téléchargement: $e');
      rethrow;
    }
  }

  // Extraire le nom de fichier de l'URL
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

  // Ajouter l'extension de fichier si elle manque
  String _ensureFileExtension(String fileName, String? mimeType) {
    if (fileName.contains('.')) return fileName;

    if (mimeType != null) {
      if (mimeType.contains('pdf')) return '$fileName.pdf';
      if (mimeType.contains('word')) return '$fileName.docx';
      if (mimeType.contains('excel')) return '$fileName.xlsx';
      if (mimeType.contains('powerpoint')) return '$fileName.pptx';
      if (mimeType.contains('text')) return '$fileName.txt';
      if (mimeType.contains('image/jpeg')) return '$fileName.jpg';
      if (mimeType.contains('image/png')) return '$fileName.png';
      if (mimeType.contains('video/mp4')) return '$fileName.mp4';
    }

    return fileName;
  }

  // Réinitialiser l'état
  void reset() {
    state = const DownloadState();
  }
}

// Provider pour l'instance du ResourceDownloadNotifier
final resourceDownloadProvider =
    StateNotifierProvider<ResourceDownloadNotifier, DownloadState>((ref) {
      return ResourceDownloadNotifier(ref);
    });
