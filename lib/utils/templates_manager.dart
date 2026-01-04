import 'dart:io';
import 'dart:isolate';
import 'package:arch_cli/src/generated/templates.g.dart';
import 'package:archive/archive.dart';

class TemplatesManager {
  static Directory? _tempDir;
  static String? _templatesRoot;

  /// Returns the path to the templates directory.
  /// If running from source, returns the local `lib/templates` path.
  /// If running as binary, extracts templates to a temp dir and returns that.
  static Future<String> getTemplatesRoot() async {
    if (_templatesRoot != null) return _templatesRoot!;

    // Check if we are running from source (dev mode)
    final sourceTemplates = Directory('${_packageRoot()}/lib/templates');
    if (sourceTemplates.existsSync()) {
      print(
          "Running in dev mode: using local templates at ${sourceTemplates.path}");
      _templatesRoot = sourceTemplates.path;
      return _templatesRoot!;
    }

    // Running as compiled binary: Extract embedded templates
    print("Running in binary mode: extracting embedded templates...");

    // Check if templatesZipBytes is empty (it's a List<int> now)
    if (templatesZipBytes.isEmpty) {
      throw Exception(
          "Templates not found! Did you run `dart run tool/generate_templates.dart` before compiling?");
    }

    _tempDir = Directory.systemTemp.createTempSync('arch_cli_templates');
    final targetPath = _tempDir!.path;
    print("Extracting to temporary directory: $targetPath");

    // Use Isolate.run to uncompress in a separate thread
    await Isolate.run(() {
      final archive = ZipDecoder().decodeBytes(templatesZipBytes);

      for (final file in archive) {
        final filename = '$targetPath/${file.name}';
        if (file.isFile) {
          final outFile = File(filename);
          outFile.createSync(recursive: true);
          outFile.writeAsBytesSync(file.content as List<int>);
        } else {
          Directory(filename).create(recursive: true);
        }
      }
    });

    _templatesRoot = targetPath;
    return _templatesRoot!;
  }

  static void cleanup() {
    if (_tempDir != null && _tempDir!.existsSync()) {
      try {
        _tempDir!.deleteSync(recursive: true);
        print("Cleaned up temporary templates directory.");
      } catch (e) {
        print("Failed to clean up temp dir: $e");
      }
    }
  }

  static String _packageRoot() {
    final uri = Platform.script;
    final path = File.fromUri(uri).parent.parent.path;
    return path;
  }
}
