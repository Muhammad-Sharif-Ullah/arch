// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pagination _$PaginationFromJson(Map<String, dynamic> json) => Pagination(
  limit: (json['limit'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  totalPage: (json['totalPage'] as num).toInt(),
  totalResult: (json['totalResult'] as num).toInt(),
);

Map<String, dynamic> _$PaginationToJson(Pagination instance) =>
    <String, dynamic>{
      'limit': instance.limit,
      'page': instance.page,
      'totalPage': instance.totalPage,
      'totalResult': instance.totalResult,
    };
