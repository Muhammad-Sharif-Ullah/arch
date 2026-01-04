
import 'package:{{project_name}}/core/clients/network/api_response.dart';
import 'package:{{project_name}}/features/{{module_name}}/domain/entities/{{module_name}}_entity.dart';
import 'package:{{project_name}}/features/{{module_name}}/domain/repositories/{{module_name}}_repo.dart';
import 'package:{{project_name}}/features/{{module_name}}/data/models/{{module_name}}_payload.dart';


abstract class {{class_name}}Repository {
  Future<Result<{{class_name}}Entity>> {{module_name}}({{class_name}}Payload payload);
}