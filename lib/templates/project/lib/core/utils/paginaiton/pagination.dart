// pagination.dart
import 'package:json_annotation/json_annotation.dart';

part '../../../../../lib/core/utils/paginaiton/pagination.g.dart';

@JsonSerializable()
class Pagination {
  final int limit;
  final int page;
  final int totalPage;
  final int totalResult;

  Pagination({
    required this.limit,
    required this.page,
    required this.totalPage,
    required this.totalResult,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationToJson(this);

  @override
  String toString() =>
      'Pagination(limit: $limit, page: $page, totalPage: $totalPage, totalResult: $totalResult)';

  static Pagination? paginationFromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return Pagination.fromJson(json);
  }

  static Map<String, dynamic>? paginationToJson(Pagination? pagination) {
    if (pagination == null) return null;
    return pagination.toJson();
  }
}
