import 'package:json_annotation/json_annotation.dart';

part 'country.g.dart';

@JsonSerializable()
class Country {
  final String name;
  final String dialCode;
  final int phoneLength;
  final String flag;
  final String isoCode;
  final String number;

  Country({
    required this.name,
    required this.dialCode,
    required this.phoneLength,
    required this.flag,
    required this.isoCode,
    this.number = '',
  });

  String get completeNumber => '$dialCode$number';

  @override
  String toString() {
    return 'Country(name: $name, dialCode: $dialCode, phoneLength: $phoneLength, flag: $flag, isoCode: $isoCode, number: $number)';
  }

  // factory default
  factory Country.defaultCountry() {
    return Country(
      name: 'Bangladesh',
      dialCode: '+880',
      phoneLength: 10,
      flag: '🇧🇩',
      isoCode: 'BD',
    );
  }

  // copy with
  Country copyWith({
    String? name,
    String? dialCode,
    int? phoneLength,
    String? flag,
    String? isoCode,
    String? number,
  }) {
    return Country(
      name: name ?? this.name,
      dialCode: dialCode ?? this.dialCode,
      phoneLength: phoneLength ?? this.phoneLength,
      flag: flag ?? this.flag,
      isoCode: isoCode ?? this.isoCode,
      number: number ?? this.number,
    );
  }

  factory Country.fromJson(Map<String, dynamic> json) =>
      _$CountryFromJson(json);

  Map<String, dynamic> toJson() => _$CountryToJson(this);
}
