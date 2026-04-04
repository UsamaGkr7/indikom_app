import 'package:dio/dio.dart';
import 'api_interceptor.dart';
// import endpoints removed - use flavor baseUrl

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  late final Dio dio;

  void init({required String baseUrl}) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
      ),
    )..interceptors.add(ApiInterceptor());
  }
}
