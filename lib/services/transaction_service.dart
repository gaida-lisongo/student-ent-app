import 'package:dio/dio.dart';
import 'package:student_app/model/transaction_model.dart';

// Réponse paginée pour les transactions
class TransactionResponse {
  final List<Transaction> data;
  final PaginationInfo pagination;

  TransactionResponse({required this.data, required this.pagination});

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> dataList = json['data'] as List<dynamic>? ?? [];
    final paginationJson = json['pagination'] as Map<String, dynamic>? ?? {};

    return TransactionResponse(
      data: dataList
          .map((item) => Transaction.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: PaginationInfo.fromJson(paginationJson),
    );
  }
}

// Modèle pour les informations de pagination
class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int pages;

  PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 50,
      total: json['total'] as int? ?? 0,
      pages: json['pages'] as int? ?? 1,
    );
  }
}

// Modèle pour le statut de recharge
class RechargeStatus {
  final String orderNumber;
  final String status; // 'pending', 'completed', 'failed'
  final int amount;
  final String currency;
  final bool success;
  final String message;
  final int? newBalance;

  RechargeStatus({
    required this.orderNumber,
    required this.status,
    required this.amount,
    required this.currency,
    required this.success,
    required this.message,
    this.newBalance,
  });

  factory RechargeStatus.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return RechargeStatus(
      orderNumber: data['orderNumber'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      amount: data['amount'] as int? ?? 0,
      currency: data['currency'] as String? ?? 'CDF',
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      newBalance: data['newBalance'] as int?,
    );
  }
}

// Service pour gérer les transactions (recharges)
class TransactionService {
  late final Dio _dio;

  static const String _baseURL = 'http://172.20.10.14:3000';

  TransactionService() {
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

    // Ajouter un intercepteur pour logger
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print(
            '🚀 TRANSACTION REQUEST: ${options.method} ${options.baseUrl}${options.path}',
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ TRANSACTION RESPONSE: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('❌ TRANSACTION ERROR: ${e.type} - ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  // Récupérer les recharges (transactions) de l'étudiant
  Future<TransactionResponse> getStudentRecharges({
    required String etudiantId,
    int limit = 50,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/api/recharge',
        queryParameters: {
          'etudiantId': etudiantId,
          'limit': limit,
          'page': page,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            response.data as Map<String, dynamic>;

        if (responseData['success'] == true) {
          return TransactionResponse.fromJson(responseData);
        } else {
          throw Exception(
            responseData['message'] ??
                "Erreur lors de la récupération des recharges",
          );
        }
      } else {
        throw Exception(
          'Erreur serveur: ${response.statusCode} ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
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
      print('❌ Erreur inattendue: $e');
      throw Exception('Erreur inattendue: $e');
    }
  }

  // Créer une nouvelle recharge
  Future<Transaction> createRecharge({
    required String etudiantId,
    required int amount,
    required String phone,
    required String description,
    required String currency,
    String paymentMethod = 'mobile_money',
  }) async {
    try {
      final response = await _dio.post(
        '/api/recharge',
        data: {
          'etudiantId': etudiantId,
          'amount': amount,
          'phone': phone,
          'description': description,
          'currency': currency,
          'paymentMethod': paymentMethod,
        },
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData =
            response.data as Map<String, dynamic>;

        if (responseData['success'] == true) {
          return Transaction.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw Exception(
            responseData['message'] ??
                "Erreur lors de la création de la recharge",
          );
        }
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création: $e');
    }
  }

  // Effectuer le paiement d'une recharge (PUT avec la transaction complète)
  Future<Transaction> payRecharge({
    required String rechargeId,
    required Map<String, dynamic> transactionData,
  }) async {
    try {
      final response = await _dio.put(
        '/api/recharge',
        queryParameters: {'rechargeId': rechargeId},
        data: transactionData,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            response.data as Map<String, dynamic>;

        if (responseData['success'] == true) {
          return Transaction.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw Exception(responseData['message'] ?? "Erreur lors du paiement");
        }
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors du paiement: $e');
    }
  }

  // Mettre à jour le statut d'une transaction (legacy)
  Future<Transaction> updateTransactionStatus({
    required String transactionId,
    required String status,
  }) async {
    try {
      final response = await _dio.put(
        '/api/recharge/$transactionId',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            response.data as Map<String, dynamic>;

        return Transaction.fromJson(
          responseData['data'] as Map<String, dynamic>,
        );
      } else {
        throw Exception('Erreur lors de la mise à jour');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Vérifier le statut d'une recharge
  Future<RechargeStatus> checkRechargeStatus(String orderNumber) async {
    try {
      final response = await _dio.get('/api/recharge/$orderNumber/status');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            response.data as Map<String, dynamic>;

        return RechargeStatus.fromJson(responseData);
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Erreur réseau';

      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Timeout de connexion';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Timeout de réception';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMessage =
            'Erreur serveur ${e.response?.statusCode}: ${e.response?.data}';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Impossible de se connecter au serveur';
      }

      print('❌ Erreur DIO: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('❌ Erreur inattendue: $e');
      throw Exception('Erreur inattendue: $e');
    }
  }
}
