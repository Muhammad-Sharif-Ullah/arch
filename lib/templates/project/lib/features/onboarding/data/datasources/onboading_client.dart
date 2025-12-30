import 'package:dio/dio.dart';
import 'package:{{project_name}}/core/clients/network/api_call_adapter.dart';
import 'package:{{project_name}}/core/clients/network/api_response.dart';
import 'package:{{project_name}}/core/clients/network/base_response.dart';
import 'package:{{project_name}}/core/clients/network/endpoints.dart';
import 'package:{{project_name}}/features/onboarding/data/models/onbading.dart';
import 'package:retrofit/retrofit.dart';

part 'onboading_client.g.dart';

@RestApi(callAdapter: ResultCallAdapter)
abstract class OnboadingClient {
  factory OnboadingClient(Dio dio, {String? baseUrl}) = _OnboadingClient;

  @GET(RemoteEndpoints.onboarding)
  Future<Result<List<OnboadingModel>>> getOnboadingData();
}
