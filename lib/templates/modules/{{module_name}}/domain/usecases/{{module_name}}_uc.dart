
import 'package:{{project_name}}/core/clients/network/api_response.dart';
import 'package:{{project_name}}/features/{{module_name}}/domain/entities/{{module_name}}_entity.dart';
import 'package:{{project_name}}/features/{{module_name}}/domain/repositories/{{module_name}}_repo.dart';
import 'package:{{project_name}}/features/{{module_name}}/data/models/{{module_name}}_payload.dart';

class {{class_name}}UseCase {
  final {{class_name}}Repository repository;

  {{class_name}}UseCase({required this.repository});

  Future<Result<{{class_name}}Entity>> call({{class_name}}Payload payload ) async {
    return await repository.{{module_name}}(payload);
  }
  
}