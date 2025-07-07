import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NetworkCall {
  static final NetworkCall _instance = NetworkCall._internal();
  factory NetworkCall() => _instance;
  NetworkCall._internal() {
    // Optionally, add interceptors or other Dio config here
  }

  final String? apiKey = dotenv.env['OPENAI_API_KEY'];
  final String url = 'https://openrouter.ai/api/v1/chat/completions';

  late final Dio dio = Dio(
    BaseOptions(
      baseUrl: url,
      headers: {
        'Content-Type': 'application/json',
        if (apiKey != null) 'Authorization': 'Bearer $apiKey',
      },
    ),
  );

  // Multifunctional methods
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(String path, {dynamic data, Options? options}) {
    return dio.post<T>(path, data: data, options: options);
  }

  Future<Response<T>> put<T>(String path, {dynamic data, Options? options}) {
    return dio.put<T>(path, data: data, options: options);
  }

  Future<Response<T>> delete<T>(String path, {dynamic data, Options? options}) {
    return dio.delete<T>(path, data: data, options: options);
  }
}
