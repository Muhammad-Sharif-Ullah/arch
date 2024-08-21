import 'dart:io';

Future<String> readContent({
  required String path,
}) async {
  final file = File(path);
  return file.readAsStringSync();
}
