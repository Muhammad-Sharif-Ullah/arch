import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:arch/utils/color_message.dart';
import 'package:cli_spin/cli_spin.dart';

Future<void> runCommand(String command, List<String> arguments) async {
  // Manually apply color to the spinner text
  final spinnerText =
      '\x1B[36mRunning $command ${arguments.join(' ')}...\x1B[0m'; // Cyan color
  final spinner = CliSpin(
    text: spinnerText,
    spinner: CliSpinners.earth,
  ).start();

  try {
    final process = await Process.start(command, arguments);

    // Collect stdout and stderr data
    final stdoutBuffer = StringBuffer();
    final stderrBuffer = StringBuffer();

    process.stdout.transform(utf8.decoder).listen((data) {
      stdoutBuffer.write(data);
    });

    process.stderr.transform(utf8.decoder).listen((data) {
      stderrBuffer.write(data);
    });

    final exitCode = await process.exitCode;

    spinner.stop();

    if (exitCode != 0) {
      throw Exception(
          '$command ${arguments.join(' ')} failed with exit code $exitCode:\n${stderrBuffer.toString()}');
    }

    // Display stdout output if available
    if (stdoutBuffer.isNotEmpty) {
      colorMsg(
          stdoutBuffer.toString(), 'reset'); // Change color for stdout output
    }

    // Always show the success message
    colorMsg(
      "\n\n✅ $command ${arguments.join(' ')} executed successfully",
      'green', // Success message in green
    );
  } catch (e) {
    spinner.stop();
    colorMsg("\n❌ Error executing: $e", 'red'); // Error message in red
  }
}
