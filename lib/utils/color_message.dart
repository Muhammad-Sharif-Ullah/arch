void printColoredMessage(String message, String color) {
  const Map<String, String> colorCodes = {
    'black': '\x1B[30m',
    'red': '\x1B[31m',
    'green': '\x1B[32m',
    'yellow': '\x1B[33m',
    'blue': '\x1B[34m',
    'magenta': '\x1B[35m',
    'cyan': '\x1B[36m',
    'white': '\x1B[37m',
    'reset': '\x1B[0m',
  };

  final colorCode = colorCodes[color.toLowerCase()] ?? colorCodes['reset'];
  print('$colorCode$message${colorCodes['reset']}');
}
