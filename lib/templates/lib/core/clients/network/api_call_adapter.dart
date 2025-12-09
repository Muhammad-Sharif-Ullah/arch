import 'dart:io';

import 'package:dio/dio.dart';
import 'package:{{project_name}}/core/clients/network/api_response.dart';
import 'package:{{project_name}}/core/clients/network/base_response.dart';
import 'package:retrofit/retrofit.dart';

// result_call_adapter.dart

/// Adapts [Future<BaseResponse<T>>] to [Future<Result<T>>]
/// Centralizes network error mapping and success/failure logic.
class ResultCallAdapter<T>
    extends CallAdapter<Future<BaseResponse<T>>, Future<Result<T>>> {
  @override
  Future<Result<T>> adapt(Future<BaseResponse<T>> Function() call) async {
    try {
      final baseResponse = await call();

      if (baseResponse.success) {
        if (baseResponse.data == null) {
          return Result.success(data: null as T);
        } else {
          // FIX: Pass the pagination data from BaseResponse to Result
          return Result.success(
            data: baseResponse.data as T,
            pagination: baseResponse.pagination?.toJson(),
          );
        }
      }

      // Handle API-level failure
      return Result.failure(
        baseResponse.error ?? 'Unknown API error',
        baseResponse.statusCode,
        baseResponse.message,
      );
    } on DioException catch (e) {
      return _mapDioExceptionToResult(e);
    } catch (e, st) {
      return Result.failure('Unexpected error: $e', null, {
        'exception': e.toString(),
        'stack_trace': st.toString(),
      });
    }
  }

  /// Maps [DioException] to appropriate [Result.failure]
  Result<T> _mapDioExceptionToResult(DioException e) {
    final response = e.response;
    final type = e.type;

    switch (type) {
      case DioExceptionType.connectionTimeout:
        return Result.failure('Connection timed out. Please try again.');

      case DioExceptionType.sendTimeout:
        return Result.failure('Request took too long to send. Please retry.');

      case DioExceptionType.receiveTimeout:
        return Result.failure('Server took too long to respond. Please retry.');

      case DioExceptionType.badResponse:
        return _handleBadResponse(response);

      case DioExceptionType.cancel:
        return Result.failure('Request was cancelled.');

      case DioExceptionType.connectionError:
        return _handleConnectionError(e);

      case DioExceptionType.badCertificate:
        return Result.failure('SSL certificate is invalid or expired.');

      case DioExceptionType.unknown:
        return Result.failure(
          'Something went wrong. Please try again later.',
          response?.statusCode,
          _extractResponseData(response),
        );
    }
  }

  /// Handles DioExceptionType.badResponse — server returned 4xx/5xx
  Result<T> _handleBadResponse(Response<dynamic>? response) {
    final data = _extractResponseData(response);

    String errorMessage =
        'Server responded with an error: ${response?.statusCode}';

    if (data != null) {
      errorMessage = data['error'] is String
          ? data['error'] as String
          : data['message'] is String
              ? data['message'] as String
              : errorMessage;
    }

    return Result.failure(errorMessage, response?.statusCode, data);
  }

  /// Handles DioExceptionType.connectionError — usually SocketException
  Result<T> _handleConnectionError(DioException e) {
    if (e.error is SocketException) {
      final socketErr = e.error! as SocketException;
      final errorCode = socketErr.osError?.errorCode;

      // Common OS-specific connection refused codes
      if (errorCode == 111 || errorCode == 61) {
        return Result.failure('Server is unreachable. Please try again later.');
      }

      // Network/DNS issues
      if (errorCode == 101 || errorCode == 7 || errorCode == 8) {
        return Result.failure(
          'No internet connection. Please check your network settings.',
        );
      }
    }

    // Generic fallback
    return Result.failure(
      'Unable to connect. Please check your internet connection.',
    );
  }

  /// Safely extracts response data as Map<String, dynamic> or null
  static Map<String, dynamic>? _extractResponseData(
    Response<dynamic>? response,
  ) {
    final dynamic rawData = response?.data;
    if (rawData is Map<String, dynamic>) {
      return Map<String, dynamic>.from(rawData);
    }
    return null;
  }
}
