import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

class LocalizationUtil {
  LocalizationUtil._();
  static Future<void> readProjectYAML(String project) async {
    final String path = 'pubspec.yaml';

    try {
      final yamlString = await File(path).readAsString();
      final editor = YamlEditor(yamlString);
      final yaml = loadYaml(yamlString);

      // --- Append flutter_localizations in dependencies ---
      final dependencies =
          Map<String, dynamic>.from(yaml['dependencies'] ?? {});
      if (!dependencies.containsKey('flutter_localizations')) {
        dependencies['flutter_localizations'] = {'sdk': 'flutter'};
        editor.update(['dependencies'], dependencies);
      }

      // --- Add flutter_gen section ---
      final flutterGenSection = {
        'output': 'lib/app/generated/',
        'line_length': 120,
        'integrations': {
          'flutter_svg': true,
          'rive': true,
          'lottie': true,
          'image': true,
        },
      };
      editor.update(['flutter_gen'], flutterGenSection);

      // --- Add flutter section ---
      final flutterSection = {
        'generate': true,
        'uses-material-design': true,
        'assets': ['assets/fonts/', 'assets/icons/', 'assets/images/'],
      };
      editor.update(['flutter'], flutterSection);

      // --- Save updated YAML ---
      await File(path).writeAsString(editor.toString());
      print('pubspec.yaml updated successfully 🎉');
    } catch (e) {
      print('Failed to read/update YAML: $e');
    }
  }
}
