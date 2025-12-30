import 'package:{{project_name}}/app/environment/production_environment.dart';
import 'package:{{project_name}}/app/view/app.dart';
import 'package:{{project_name}}/bootstrap.dart';

Future<void> main() async {
  await bootstrap(builder: App.new, environment: ProductionEnvironment());
}
