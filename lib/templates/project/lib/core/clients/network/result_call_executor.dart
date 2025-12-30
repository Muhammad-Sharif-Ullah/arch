import 'dart:io';
import 'package:dio/dio.dart';
import 'package:{{project_name}}/core/clients/network/api_response.dart';
import 'package:{{project_name}}/core/clients/network/base_response.dart';

typedef ApiCall<T> = Future<Response<Map<String, dynamic>>> Function();

final class ResultCallExecutor {
  const ResultCallExecutor();

  Future<Result<T>> execute<T>(
    ApiCall<T> call,
    T Function(Object? json) fromJsonT,
  ) async {
    try {
      final response = await call();

      final baseResponse = BaseResponse<T>.fromJson(response.data!, fromJsonT);

      if (baseResponse.success) {
        return Result.success(
          data: baseResponse.data as T,
          pagination: baseResponse.pagination?.toJson(),
        );
      }

      return Result.failure(
        baseResponse.error ?? 'Unknown API error',
        baseResponse.statusCode,
        baseResponse.message,
      );
    } on DioException catch (e) {
      return _mapDioException<T>(e);
    } catch (e, st) {
      return Result.failure('Unexpected error', null, {
        'exception': e.toString(),
        'stack_trace': st.toString(),
      });
    }
  }

  /* ===== list wrapper ===== */
  Future<Result<List<T>>> executeList<T>(
    ApiCall call,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) async {
    final res = await execute<List<T>>(call, (listJson) {
      // BaseResponse<List<T>>  ->  listJson is List<dynamic>
      final list = (listJson as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(fromJsonT)
          .toList();
      return list;
    });
    return res;
  }

  /* ---------- helpers ---------- */

  Result<T> _mapDioException<T>(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Result.failure('Connection timeout');

      case DioExceptionType.sendTimeout:
        return Result.failure('Send timeout');

      case DioExceptionType.receiveTimeout:
        return Result.failure('Receive timeout');

      case DioExceptionType.badResponse:
        return Result.failure(
          'Server error',
          e.response?.statusCode,
          _extractData(e.response),
        );

      case DioExceptionType.connectionError:
        if (e.error is SocketException) {
          return Result.failure('No internet connection');
        }
        return Result.failure('Connection error');

      case DioExceptionType.cancel:
        return Result.failure('Request cancelled');

      case DioExceptionType.badCertificate:
        return Result.failure('Bad SSL certificate');

      case DioExceptionType.unknown:
        return Result.failure('Unknown network error');
    }
  }

  Map<String, dynamic>? _extractData(Response<dynamic>? response) {
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }
}
