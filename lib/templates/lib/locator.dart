import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:{{project_name}}/app/environment/app_environment.dart';
import 'package:{{project_name}}/core/clients/network/network_client.dart';
import 'package:get_it/get_it.dart';

/// [Locator] is responsible for locating and registering all the
/// services of the application.
abstract final class Locator {
  /// [GetIt] instance
  @visibleForTesting
  static final instance = GetIt.instance;

  /// Returns instance of [NetworkClient]
  static NetworkClient get networkClient => instance<NetworkClient>();

  /// Responsible for registering all the dependencies
  static Future<void> locateServices({
    required AppEnvironment environment,
  }) async {
    instance
      // Clients
      // ..registerLazySingleton(
      //   () => NetworkClient(dio: instance(), baseUrl: environment.baseUrl),
      // )
      // Client Dependencies
      ..registerLazySingleton<Dio>(() {
        final dio = Dio();

        // Add your interceptor here
        // Optional: Enable logging (great for debugging)
        dio.interceptors.add(
          LogInterceptor(requestBody: true, responseBody: true),
        );
        return dio;
      });
  }
}
