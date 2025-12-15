import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:student_app/model/student_model.dart'; // Importez le modèle

// Clé de stockage sécurisée pour le "token" (votre _id principale)
const _secureStorageKey = 'STUDENT_SESSION_ID';

// =======================================================
// 1. DÉFINITION DU SERVICE D'AUTHENTIFICATION (AuthService)
// =======================================================

class AuthService {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // URL pour la simulation de l'API (votre adresse IP locale)
  static const String _baseURL = 'http://172.20.10.14:3000';

  AuthService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseURL,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Ajouter un intercepteur pour logger les requêtes/réponses
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print(
            '🚀 REQUEST: ${options.method} ${options.baseUrl}${options.path}',
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ RESPONSE: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('❌ ERROR: ${e.type} - ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  // Récupère l'ID de session stocké localement
  Future<String?> getSessionId() async {
    return await _storage.read(key: _secureStorageKey);
  }

  // Effectue la connexion en utilisant l'URL (endpoint) fourni par le QR code
  // L'URL scannée est de la forme: http://172.20.10.14:3000/etudiant/SESSION_ID
  Future<InscriptionData> authenticateWithEndpoint(String endpoint) async {
    try {
      // Transformer l'URL complète en chemin relatif pour Dio
      final uri = Uri.parse(endpoint);
      final path = uri.path;

      print('🔐 Authentification: $path');

      final response = await _dio.get(path);

      // Vérifier la réponse
      if (response.statusCode == 200) {
        // Vérifier si c'est un objet imbédié avec un champ 'data'
        final Map<String, dynamic> responseData =
            response.data as Map<String, dynamic>;

        // Si la réponse a un champ 'success' et 'data', utiliser directement
        if (responseData.containsKey('success') &&
            responseData.containsKey('data')) {
          if (responseData['success'] == true) {
            final inscriptionData = InscriptionData.fromJson(responseData);

            // Stockage sécurisé de l'ID de session
            await _storage.write(
              key: _secureStorageKey,
              value: inscriptionData.id,
            );

            print('✅ Authentification réussie: ${inscriptionData.id}');
            return inscriptionData;
          } else {
            throw Exception(
              responseData['message'] ?? "Échec de l'authentification.",
            );
          }
        } else {
          // Si la réponse est directement les données (sans wrapper)
          try {
            final inscriptionData = InscriptionData.fromJson({
              'data': responseData,
              'success': true,
            });

            await _storage.write(
              key: _secureStorageKey,
              value: inscriptionData.id,
            );

            print('✅ Authentification réussie: ${inscriptionData.id}');
            return inscriptionData;
          } catch (e) {
            throw Exception('Format de réponse invalide: $e');
          }
        }
      } else {
        throw Exception(
          'Erreur serveur: ${response.statusCode} ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      // Gérer les différents types d'erreurs DIO
      String errorMessage = 'Erreur réseau';

      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage =
            'Timeout de connexion - le serveur met trop de temps à répondre';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Timeout de réception - pas de réponse du serveur';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMessage =
            'Erreur serveur ${e.response?.statusCode}: ${e.response?.data}';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage =
            'Impossible de se connecter au serveur. Vérifiez votre IP: $_baseURL';
      }

      print('❌ Erreur DIO: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      // Gérer d'autres erreurs
      print('❌ Erreur inattendue: $e');
      throw Exception('Erreur inattendue lors de la connexion: $e');
    }
  }

  // Déconnexion : supprime l'ID de session stocké
  Future<void> logout() async {
    await _storage.delete(key: _secureStorageKey);
  }
}

// =======================================================
// 2. DÉFINITION DU PROVIDER (AUTH STATE)
// =======================================================

// L'état que notre UI va écouter
class AuthState {
  final bool isLoading;
  final InscriptionData? user;
  final String? errorMessage;

  AuthState({this.isLoading = false, this.user, this.errorMessage});

  AuthState copyWith({
    bool? isLoading,
    InscriptionData? user,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user, // Note: si user est null, l'utilisateur est déconnecté
      errorMessage: errorMessage,
    );
  }
}

// Provider de l'état d'authentification
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  // Le notifier a accès au AuthService
  return AuthNotifier(AuthService());
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    // Vérifier l'état de la session au démarrage
    checkSession();
  }

  // Vérifie si un token est déjà stocké
  Future<void> checkSession() async {
    state = state.copyWith(isLoading: true);
    final sessionId = await _authService.getSessionId();

    if (sessionId != null) {
      // Si un ID est trouvé, on le reconstruit comme une URL
      final simulatedEndpoint =
          '${AuthService._baseURL}/api/parcours/$sessionId';
      // Tentative de re-validation ou de chargement des données
      await signIn(simulatedEndpoint);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  // Logique de connexion
  Future<void> signIn(String endpoint) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final authData = await _authService.authenticateWithEndpoint(endpoint);
      // Succès: stocker les données utilisateur
      state = AuthState(user: authData, isLoading: false);
    } catch (e) {
      // Échec: afficher l'erreur et rester déconnecté
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
        user: null,
      );
    }
  }

  // Logique de déconnexion
  Future<void> signOut() async {
    await _authService.logout();
    state = AuthState(); // Réinitialiser l'état
  }
}
