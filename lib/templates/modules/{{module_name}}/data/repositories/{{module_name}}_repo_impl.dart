import 'package:{{project_name}}/app/environment/app_environment.dart';
import 'package:{{project_name}}/core/clients/network/api_response.dart';
import 'package:{{project_name}}/features/{{module_name}}/data/datasources/{{module_name}}_moc_client.dart';
import 'package:{{project_name}}/features/{{module_name}}/data/datasources/{{module_name}}_rest_client.dart';
import 'package:{{project_name}}/features/{{module_name}}/data/models/{{module_name}}_model.dart';
import 'package:{{project_name}}/features/{{module_name}}/domain/repositories/{{module_name}}_repo.dart';
import 'package:{{project_name}}/features/{{module_name}}/data/models/{{module_name}}_payload.dart';
import 'package:{{project_name}}/app/environment/production_environment.dart';


class I{{class_name}}Repository extends {{class_name}}Repository{
  final {{class_name}}MockClient mocClient;
  final AppEnvironment environment;
  final {{class_name}}RestClient remote;

  I{{class_name}}Repository({
    required this.mocClient,
    required this.remote,
    required this.environment,
  });
  @override
  Future<Result<{{class_name}}Model>> {{module_name}}({{class_name}}Payload payload) async {
     if (environment is ProductionEnvironment) {
      return await remote.{{module_name}}(payload: payload);
    } else {
      return await mocClient.{{module_name}}(payload: payload);
    }
  }
}