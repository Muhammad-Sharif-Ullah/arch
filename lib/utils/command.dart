import 'dart:io';

Future<void> runCommand(
  String command,
  List<String> arguments, {
  String spinnerRunning = 'Running...',
  String spinnerIcon = '✅',
  String spinnerDone = 'Your process is done',
}) async {
  final process = await Process.start(command, arguments);
  await stdout.addStream(process.stdout);
  await stderr.addStream(process.stderr);
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    throw Exception(
        'Command $command ${arguments.join(' ')} failed with exit code $exitCode');
  }
}
