import 'dart:io';

import 'package:jinja/jinja.dart';
import 'package:jinja/loaders.dart';
import 'package:path/path.dart' as p;

class LibFolderTemplating {
  LibFolderTemplating._();

  static Future<void> renderTemplatesFolder({
    required String templatesRoot, // absolute path to code/arch/lib/templates
    required String srcFolder, // 'lib' (folder inside templatesRoot)
    required String destRoot, // output project root, e.g. './my_project'
    Map<String, Object?> globals = const {},
  }) async {
    // Normalize paths
    final templatesPath = p.normalize(templatesRoot);
    final templateDir = Directory(p.join(templatesPath, srcFolder));
    if (!templateDir.existsSync()) {
      throw Exception('Template folder not found: ${templateDir.path}');
    }

    final env = Environment(
      loader: FileSystemLoader(paths: [templatesPath]),
      globals: globals,
      autoReload: true,
      // You can set trimBlocks/leftStripBlocks if needed:
      // trimBlocks: true,
      // leftStripBlocks: true,
    );

    // Which extensions we treat as text/template files to render
    final textExtensions = <String>{
      '.dart',
      '.yaml',
      '.yml',
      '.json',
      '.md',
      '.txt',
      '.html',
      '.htm',
    };

    await for (final entity
        in templateDir.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;

      final relativePath = p.relative(entity.path, from: templatesPath);
      final destPath = p.join(destRoot, relativePath);

      // Ensure destination directory exists
      Directory(p.dirname(destPath)).createSync(recursive: true);

      final ext = p.extension(entity.path).toLowerCase();

      if (textExtensions.contains(ext)) {
        // Render template file by its path relative to loader root
        try {
          final template = env.getTemplate(relativePath);
          final rendered = template.render({
            // your template variables (can include globals too)
            ...globals,
          });

          // Write rendered text
          File(destPath).writeAsStringSync(rendered);
          print('Rendered -> $relativePath -> $destPath');
        } catch (e) {
          // Fallback: if env.getTemplate fails for whatever reason,
          // try reading the file as text and render from string.
          try {
            final content = await entity.readAsString();
            final template = env.fromString(content);
            final rendered = template.render({...globals});
            await File(destPath).writeAsString(rendered);
            print('Rendered (fromString) -> $relativePath -> $destPath');
          } catch (e2) {
            print('Failed to render text file $relativePath: $e2');
          }
        }
      } else {
        // Binary/non-template: copy bytes as-is (images, fonts, etc.)
        await entity.copy(destPath);
        print('Copied (binary) -> $relativePath -> $destPath');
      }
    }
  }
}
