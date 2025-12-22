import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider(
  (ref) => Dio(
    BaseOptions(
      baseUrl: 'https://app.inbtp.net/api', // Replace with your API base URL
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  ),
);
