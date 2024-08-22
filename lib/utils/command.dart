import 'dart:async';
import 'dart:io';

import 'package:arch/utils/color_message.dart';
import 'package:cli_spinner/cli_spinner.dart';

Future<void> runCommand(
  String command,
  List<String> arguments,
) async {
  final spinner = Spinner('Running $command ${arguments.join(' ')}...');
  spinner.start();

  final stdoutController = StreamController<List<int>>();
  final stderrController = StreamController<List<int>>();

  stdoutController.stream.listen((data) {
    stdout.add(data);
  });

  stderrController.stream.listen((data) {
    stderr.add(data);
  });

  try {
    final process = await Process.start(command, arguments);
    process.stdout.pipe(stdoutController);
    process.stderr.pipe(stderrController);
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw Exception(
          'Command $command ${arguments.join(' ')} failed with exit code $exitCode');
    }
    printColoredMessage("\n\n✅ $command ${arguments.join(' ')}\n", 'green');
  } finally {
    await stdoutController.close();
    await stderrController.close();
    spinner.stop();
  }
}
