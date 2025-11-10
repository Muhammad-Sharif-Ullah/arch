import 'package:{{project_name}}/core/clients/network/pagination.dart';

class BaseResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;
  final Map<String, dynamic>? message;
  final Pagination? pagination;

  BaseResponse({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
    this.message,
    this.pagination,
  });

  /// Factory to parse JSON into [BaseResponse<T>]
  /// [fromJsonT] is a function to convert raw JSON (dynamic) into type [T]
  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT, // ✅ Use `dynamic` for flexibility
  ) {
    // Normalize success flag
    final bool parsedSuccess = _parseSuccess(json);

    // Extract data field (supports 'result', 'data', 'paths')
    final dynamic rawData = _extractDataField(json);

    // Parse data using provided converter
    final T? parsedData = _parseData(rawData, fromJsonT);

    // Extract error message
    final String? parsedError = _parseError(json);

    // Extract status code
    final int? parsedStatusCode = json['statusCode'] as int?;

    // Extract message map (only if it's a Map)
    final Map<String, dynamic>? parsedMessage = _parseMessage(json);

    // Extract pagination
    final Pagination? parsedPagination = _parsePagination(json);

    return BaseResponse<T>(
      success: parsedSuccess,
      data: parsedData,
      error: parsedError,
      statusCode: parsedStatusCode,
      message: parsedMessage,
      pagination: parsedPagination,
    );
  }

  /// Converts this instance back to JSON
  /// [toJsonT] is an optional function to convert [T] to JSON-compatible format
  Map<String, dynamic> toJson(Object? Function(T)? toJsonT) {
    final Map<String, dynamic> json = {'success': success};

    if (data != null && toJsonT != null) {
      json['result'] = toJsonT(data as T);
    }

    if (error != null) json['error'] = error;
    if (statusCode != null) json['statusCode'] = statusCode;
    if (message != null) json['message'] = Map<String, dynamic>.from(message!);
    if (pagination != null) json['pagination'] = pagination!.toJson();

    return json;
  }

  // ─── PRIVATE HELPERS ──────────────────────────────────────────────────

  /// Parses the 'success' field, falling back to 'status'
  static bool _parseSuccess(Map<String, dynamic> json) {
    final success = json['success'];
    if (success != null) return success as bool;
    final status = json['status'];
    return status is bool ? status : false;
  }

  /// Extracts the data field from known keys: 'result', 'data', 'paths'
  static dynamic _extractDataField(Map<String, dynamic> json) {
    if (json.containsKey('result')) return json['result'];
    if (json.containsKey('data')) return json['data'];
    if (json.containsKey('paths')) return json['paths'];
    return null;
  }

  /// Safely parses data using the provided converter
  static T? _parseData<T>(dynamic rawData, T Function(dynamic) fromJsonT) {
    if (rawData == null) return null;

    try {
      return fromJsonT(rawData);
    } on Exception catch (e) {
      // Log or handle parsing error if needed
      // For now, rethrow with context for debugging
      throw Exception('Failed to parse response data: $e');
    }
  }

  /// Extracts error message, falling back to 'message' if 'error' is absent
  static String? _parseError(Map<String, dynamic> json) {
    final error = json['error'];
    if (error != null) return error as String?;

    final message = json['message'];
    return message is String ? message : null;
  }

  /// Extracts message map only if it's a Map<String, dynamic>
  static Map<String, dynamic>? _parseMessage(Map<String, dynamic> json) {
    final message = json['message'];
    return message is Map<String, dynamic>
        ? Map<String, dynamic>.from(message)
        : null;
  }

  /// Parses pagination if present and valid
  static Pagination? _parsePagination(Map<String, dynamic> json) {
    final pagination = json['pagination'];
    if (pagination is Map<String, dynamic>) {
      return Pagination.fromJson(pagination);
    }
    return null;
  }
}
