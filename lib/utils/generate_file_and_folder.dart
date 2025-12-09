import 'dart:io';

import 'package:arch_cli/arch.dart';

Future<void> generateFileAndFolder({
  required String filePath,
  required String content,
}) async {
  // get the parent directory

  final parent = Directory(filePath).parent;
  print(parent);

  if (!await parent.exists()) {
    // only create folder
    await parent.create(recursive: true);
    print('Parent directory created successfully');
  }

  await writeFile(path: filePath, content: content);
}
