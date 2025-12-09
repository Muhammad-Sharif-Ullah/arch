// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Country _$CountryFromJson(Map<String, dynamic> json) => Country(
  name: json['name'] as String,
  dialCode: json['dialCode'] as String,
  phoneLength: (json['phoneLength'] as num).toInt(),
  flag: json['flag'] as String,
  isoCode: json['isoCode'] as String,
  number: json['number'] as String? ?? '',
);

Map<String, dynamic> _$CountryToJson(Country instance) => <String, dynamic>{
  'name': instance.name,
  'dialCode': instance.dialCode,
  'phoneLength': instance.phoneLength,
  'flag': instance.flag,
  'isoCode': instance.isoCode,
  'number': instance.number,
};
