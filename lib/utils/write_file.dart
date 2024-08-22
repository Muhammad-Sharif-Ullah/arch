import 'dart:io';

Future<void> writeFile({
  required String path,
  required String content,
}) async {
  final file = File(path);
  await file.writeAsString(content);
}
