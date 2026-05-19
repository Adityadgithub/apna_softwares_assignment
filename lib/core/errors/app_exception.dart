class AppException implements Exception {
  AppException(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.code});
}

class CacheException extends AppException {
  CacheException(super.message);
}
