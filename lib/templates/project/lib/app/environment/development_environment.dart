import 'package:{{project_name}}/app/environment/app_environment.dart';
import 'package:envied/envied.dart';

part '../../../../lib/app/environment/development_environment.g.dart';

@Envied(obfuscate: true, path: AppEnvironment.developmentPath)
final class DevelopmentEnvironment implements AppEnvironment {
  DevelopmentEnvironment();

  @override
  @EnviedField(varName: 'BASE_URL')
  final String baseUrl = _DevelopmentEnvironment.baseUrl;
}
