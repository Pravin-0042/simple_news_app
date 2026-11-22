enum NetworkErrorType { connection, timeout, badResponse, unexpected }

class NetworkException implements Exception {
  const NetworkException({
    required this.type,
    required this.message,
    this.statusCode,
    this.cause,
  });

  final NetworkErrorType type;
  final String message;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() {
    final status = statusCode == null ? '' : ' (status: $statusCode)';
    return 'NetworkException: $message$status';
  }
}
