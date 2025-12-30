// paginated_response.dart
import 'package:{{project_name}}/core/utils/paginaiton/pagination.dart';
import 'package:json_annotation/json_annotation.dart';

part '../../../../../lib/core/utils/paginaiton/paginated_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final List<T> data;
  final Pagination pagination;
  final String? error;
  final int? statusCode;

  PaginatedResponse({
    required this.data,
    required this.pagination,
    this.error,
    this.statusCode,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);
}
