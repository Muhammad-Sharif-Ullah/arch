import 'package:{{project_name}}/app/environment/app_environment.dart';
import 'package:envied/envied.dart';

part '../../../../lib/app/environment/production_environment.g.dart';

@Envied(obfuscate: true, path: AppEnvironment.productionPath)
final class ProductionEnvironment implements AppEnvironment {
  ProductionEnvironment();

  @override
  @EnviedField(varName: 'BASE_URL')
  final String baseUrl = _ProductionEnvironment.baseUrl;
}
