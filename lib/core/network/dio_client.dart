import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class DioClient {
  DioClient({Logger? logger})
      : _log = logger ?? Logger(),
        _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {'Accept': 'application/json'},
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          _log.w('API error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final Logger _log;

  Dio get dio => _dio;
}
