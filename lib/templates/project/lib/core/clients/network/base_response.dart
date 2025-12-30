import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:{{project_name}}/core/utils/paginaiton/pagination.dart';

part 'base_response.g.dart';

@JsonSerializable(genericArgumentFactories: true, explicitToJson: true)
class BaseResponse<T> extends Equatable {
  @JsonKey(name: 'status')
  final bool success;

  final String? error;
  final int? statusCode;
  final Map<String, dynamic>? message;

  @JsonKey(
    name: 'pagination',
    toJson: Pagination.paginationToJson,
    fromJson: Pagination.paginationFromJson,
  )
  final Pagination? pagination;

  @JsonKey(name: 'data')
  final T? data;

  const BaseResponse({
    required this.success,
    this.error,
    this.statusCode,
    this.message,
    this.pagination,
    this.data,
  });

  @override
  List<Object?> get props => [
        success,
        error,
        statusCode,
        message,
        pagination,
        data,
      ];

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$BaseResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$BaseResponseToJson(this, toJsonT);
}
