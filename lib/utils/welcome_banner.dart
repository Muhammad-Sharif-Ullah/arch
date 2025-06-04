import 'dart:io';

import 'read_logo.dart';

class WelcomeBanner {
  void call() {
    final String logo = readLogo();
    final int terminalWidth = stdout.terminalColumns;

    // Split the logo into lines once
    final List<String> logoLines = logo.split('\n');

    // Calculate the width of the widest line in the logo
    final int logoWidth =
        logoLines.map((line) => line.length).reduce((a, b) => a > b ? a : b);

    // Calculate the padding for centering the logo
    final int padding = (terminalWidth - logoWidth) ~/ 2;

    // Print the logo with padding
    for (final line in logoLines) {
      stdout.writeln('${' ' * padding}$line');
    }

    // Calculate padding for the welcome message relative to the logo width
    final int messagePadding = (logoWidth - "Welcome To".length) ~/ 2;
    stdout.writeln('${' ' * (padding + messagePadding)}Welcome To');

    final int generatorPadding =
        (logoWidth - "Flutter Clean Architecture Template Generator".length) ~/
            2;
    stdout.writeln(
        '${' ' * (padding + generatorPadding)}Flutter Clean Architecture Template Generator');

    // Print a horizontal separator
    stdout.writeln('-' * terminalWidth);
  }
}
