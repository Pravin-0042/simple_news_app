import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../errors/network_exception.dart';

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  static Dio createDio() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.requestTimeout,
        sendTimeout: ApiConstants.requestTimeout,
        receiveTimeout: ApiConstants.requestTimeout,
        responseType: ResponseType.json,
        headers: const {Headers.acceptHeader: 'application/json'},
      ),
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, Object?>? queryParameters,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters);
    } catch (error, stackTrace) {
      final exception = error is DioException
          ? _fromDioException(error)
          : NetworkException(
              type: NetworkErrorType.unexpected,
              message: 'An unexpected network error occurred.',
              cause: error,
            );
      Error.throwWithStackTrace(exception, stackTrace);
    }
  }

  NetworkException _fromDioException(DioException exception) {
    final statusCode = exception.response?.statusCode;
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          type: NetworkErrorType.timeout,
          message: exception.message ?? 'The request timed out.',
          statusCode: statusCode,
          cause: exception,
        );
      case DioExceptionType.connectionError:
        return NetworkException(
          type: NetworkErrorType.connection,
          message: exception.message ?? 'Unable to connect to the server.',
          statusCode: statusCode,
          cause: exception,
        );
      case DioExceptionType.badResponse:
        return NetworkException(
          type: NetworkErrorType.badResponse,
          message:
              exception.message ?? 'The server returned an error response.',
          statusCode: statusCode,
          cause: exception,
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.unknown:
        return NetworkException(
          type: NetworkErrorType.unexpected,
          message: exception.message ?? 'An unexpected network error occurred.',
          statusCode: statusCode,
          cause: exception,
        );
    }
  }
}
