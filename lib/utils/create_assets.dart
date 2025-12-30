import 'dart:convert';
import 'dart:io';

import 'package:arch_cli/arch.dart';
import 'package:arch_cli/utils/templates_manager.dart';
import 'package:json2yaml/json2yaml.dart';
import 'package:yaml/yaml.dart';

class CreateAssets {
  CreateAssets._();

  /// This function is intentionally left empty.
  /// It serves as a placeholder for future asset creation logic.
  static Future<void> createAssets({required final String projectDirectory}) async {
    print(
        "Creating assets in $projectDirectory, ${Directory.current.parent.path}");

    final yamlFile =
        '${Directory.current.parent.path}/$projectDirectory/pubspec.yaml';

    final yaml = File(yamlFile).readAsStringSync();
    var doc = loadYaml(yaml);

    // Convert YAML -> JSON Map
    final jsonToMap = json.decode(json.encode(doc));

    // Ensure flutter key exists
    jsonToMap['flutter'] ??= {};

    // Add assets
    jsonToMap['flutter']['assets'] = [
      'assets/data/',
      'assets/images/',
      'assets/icons/',
      'assets/fonts/',
      'environment/',
    ];

    // Convert back to YAML
    String updatedYaml = json2yaml(jsonToMap);

    // ✅ Commented font block
    const commentedFonts = '''
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
  # ''';

    // ✅ Append commented fonts after flutter section
    if (!updatedYaml.contains('# fonts:')) {
      updatedYaml = '$updatedYaml\n$commentedFonts';
    }

    // Write back to file
    File(yamlFile).writeAsStringSync(updatedYaml);

     // Asset folder collection and copy logic is now handled by LibFolderTemplating in Project Controller
  }
}
