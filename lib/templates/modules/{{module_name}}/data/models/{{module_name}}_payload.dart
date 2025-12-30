import 'package:json_annotation/json_annotation.dart';

part '{{module_name}}_payload.g.dart';

@JsonSerializable()
class {{class_name}}Payload {
  final String name;

  {{class_name}}Payload({required this.name});
  factory {{class_name}}Payload.fromJson(Map<String, dynamic> json) =>
      _${{class_name}}PayloadFromJson(json);
  Map<String, dynamic> toJson() => _${{class_name}}PayloadToJson(this);
}
