import 'dart:io';

int terminalWidth() {
  if (!stdout.hasTerminal) {
    print('Stdout not attached to a terminal! Exiting...');
    exit(0);
  }
  // ProcessSignal.sigwinch.watch().listen((_) {
  //   print('${stdout.terminalLines} x ${stdout.terminalColumns}');
  // });
  return stdout.terminalColumns;
}
