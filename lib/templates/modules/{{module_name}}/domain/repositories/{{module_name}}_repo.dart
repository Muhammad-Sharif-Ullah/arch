
import 'package:{{project_name}}/core/clients/network/api_response.dart';
import 'package:{{project_name}}/features/{{module_name}}/domain/entities/{{module_name}}_entity.dart';


abstract class {{class_name}}Repository {
  Future<Result<{{class_name}}Entity>> {{module_name}}();
}