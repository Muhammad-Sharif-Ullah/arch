import 'dart:developer';

import 'package:arch/arch.dart' as arch;
import 'dart:io';

void main(List<String> arguments) {
  final String logo = arch.readLogo();
  final int terminalWidth = arch.terminalWidth();

  // calculate String width of the logo
  final int logoWidth =
      logo.split('\n').map((e) => e.length).reduce((a, b) => a > b ? a : b);
  
  // calculate String height of the logo
  final int logoHeight =   

  // calculate the padding
  final int padding = (terminalWidth - logoWidth) ~/ 2;

  // print the logo with padding

  stdout.write(logo);
  stdout.write('\n');
}
