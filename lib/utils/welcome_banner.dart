import 'dart:io';

import 'package:arch/utils/get_terminal_dimension.dart';

import 'read_logo.dart';

class WelcomeBanner {
  void call() {
    final String logo = readLogo();
    final int width = terminalWidth();

    // calculate String width of the logo
    final int logoWidth =
        logo.split('\n').map((e) => e.length).reduce((a, b) => a > b ? a : b);

    // calculate String height of the logo
    final int logoHeight = logo.split('\n').length;

    // calculate the padding
    final int padding = (width - logoWidth) ~/ 2;

    // print the logo with padding

    // stdout.write(logo);
    for (int i = 0; i < logoHeight; i++) {
      stdout.write(' ' * padding);
      stdout.write(logo.split('\n')[i]);
      stdout.write(' ' * padding);
    }
    stdout.write('\n');
    stdout.write("${" " * padding}    Welcome To \n");
    stdout.write(
        '${" " * (width - logoWidth - padding - 10)}Flutter Clean Architecture Template Generator\n');
    stdout.write("${'-' * width}\n");
  }
}
