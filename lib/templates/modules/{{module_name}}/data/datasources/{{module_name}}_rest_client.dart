import 'package:{{project_name}}/core/clients/network/endpoints.dart';
import 'package:{{project_name}}/core/clients/network/network_client.dart';
import 'package:{{project_name}}/core/clients/network/result_call_executor.dart';
import 'package:{{project_name}}/features/{{module_name}}/data/models/{{module_name}}_payload.dart';
import 'package:{{project_name}}/features/{{module_name}}/data/models/{{module_name}}_model.dart';
import 'package:{{project_name}}/core/clients/network/api_response.dart';

class {{class_name}}RestClient {
  final NetworkClient client;
  final ResultCallExecutor executor;

  {{class_name}}RestClient({required this.client, ResultCallExecutor? executor})
    : executor = executor ?? const ResultCallExecutor();

   Future<Result<{{class_name}}Model>> {{module_name}}({required {{class_name}}Payload payload}) {
    return executor.execute<{{class_name}}Model>(
      () => client.post<Map<String, dynamic>>(
        RemoteEndpoints.login,
        data: payload.toJson(),
      ),
      (json) => {{class_name}}Model.fromJson(json as Map<String, dynamic>),
    );
  }
}