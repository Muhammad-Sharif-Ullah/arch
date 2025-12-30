import 'package:json_annotation/json_annotation.dart';
import 'package:{{project_name}}/features/{{module_name}}/domain/entities/{{module_name}}_entity.dart';

part '{{module_name}}_model.g.dart';

@JsonSerializable()
class {{class_name}}Model extends {{class_name}}Entity {
  const {{class_name}}Model({required super.name});

    factory {{class_name}}Model.fromJson(Map<String, dynamic> json) =>
      _${{class_name}}ModelFromJson(json);
  Map<String, dynamic> toJson() => _${{class_name}}ModelToJson(this);
}
