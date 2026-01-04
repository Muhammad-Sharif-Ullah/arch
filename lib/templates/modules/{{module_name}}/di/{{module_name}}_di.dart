// Do not remove this type of comment
/*
  /// ---------------------------
  /// Auto generated file
  /// Do not edit manually.
  /// Run `flutter pub run build_runner build --delete-conflicting-outputs`
  /// to regenerate this file.
  /// ---------------------------
*/


import 'package:get_it/get_it.dart';
import 'package:{{project_name}}/app/environment/app_environment.dart';
import 'package:{{project_name}}/features/{{module_name}}/data/datasources/{{module_name}}_moc_client.dart';
import 'package:{{project_name}}/features/{{module_name}}/data/datasources/{{module_name}}_rest_client.dart';
import 'package:{{project_name}}/features/{{module_name}}/data/repositories/{{module_name}}_repo_impl.dart';
import 'package:{{project_name}}/features/{{module_name}}/domain/repositories/{{module_name}}_repo.dart';
import 'package:{{project_name}}/features/{{module_name}}/domain/usecases/{{module_name}}_uc.dart';

class {{class_name}}Di {
  static void register(GetIt instance, {required AppEnvironment environment}) {
    // ---------------------------
    // Data sources
    // ---------------------------

    instance.registerFactory<{{class_name}}MockClient>(() => {{class_name}}MockClient());

    instance.registerFactory<{{class_name}}RestClient>(
      () => {{class_name}}RestClient(client: instance()),
    );

    // ---------------------------
    // Repository
    // ---------------------------

    instance.registerFactory<{{class_name}}Repository>(
      () => I{{class_name}}Repository(
        mocClient: instance(),
        remote: instance(),
        environment: instance(),
      ),
    );

    // ---------------------------
    // Use case
    // ---------------------------

    instance.registerFactory<{{class_name}}UseCase>(
      () => {{class_name}}UseCase(repository: instance()),
    );

    // ---------------------------
    // State management
    // ---------------------------

  }
}
