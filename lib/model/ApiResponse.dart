// --- Modèle de réponse API ---
class ApiResponse<T> {
  final bool success;
  final T data;

  ApiResponse({required this.success, required this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] as T,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data};
  }
}
