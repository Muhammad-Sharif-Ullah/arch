
import 'package:{{project_name}}/core/clients/network/api_response.dart';
import 'package:{{project_name}}/features/{{module_name}}/domain/entities/{{module_name}}_entity.dart';
import 'package:{{project_name}}/features/{{module_name}}/domain/repositories/{{module_name}}_repo.dart';

class {{class_name}}UseCase {
  final {{class_name}}Repository repository;

  {{class_name}}UseCase({required this.repository});

  Future<Result<{{class_name}}Entity>> call() async {
    return await repository.{{module_name}}();
  }
  
}