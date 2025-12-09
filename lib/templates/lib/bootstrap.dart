import 'dart:async';

import 'package:flutter/services.dart';
import 'package:{{project_name}}/app/environment/app_environment.dart';
import 'package:{{project_name}}/core/utils/device_info/device_info_utils.dart';
import 'package:{{project_name}}/core/utils/logger/logger_utils.dart';
import 'package:{{project_name}}/core/utils/package_info/package_info_utils.dart';
import 'package:{{project_name}}/core/di/locator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

Future<void> bootstrap({
  required FutureOr<Widget> Function() builder,
  required AppEnvironment environment,
}) async {
  FlutterError.onError = (details) {
    LoggerUtils.instance.logFatalError(
      details.exceptionAsString(),
      details.stack,
    );
  };
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Hydrated BLoc
      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: kIsWeb
            ? HydratedStorageDirectory.web
            : HydratedStorageDirectory((await getTemporaryDirectory()).path),
      );

      // Initialize Locator and Utils
      await Future.wait([
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
        ),
        Locator.setup(environment: environment),
        PackageInfoUtils.init(),
        DeviceInfoUtils.init(),
      ]);

      runApp(await builder());
    },
    (error, stackTrace) {
      LoggerUtils.instance.logFatalError(error.toString(), stackTrace);
    },
  );
}
