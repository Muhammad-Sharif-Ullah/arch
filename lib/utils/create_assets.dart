import 'dart:convert';
import 'dart:io';

import 'package:arch/arch.dart';
import 'package:json2yaml/json2yaml.dart';
import 'package:yaml/yaml.dart';

class CreateAssets {
  CreateAssets._();

  /// This function is intentionally left empty.
  /// It serves as a placeholder for future asset creation logic.
  static void createAssets({required final String projectDirectory}) {
    // print(
    //     "Creating assets in $projectDirectory, ${Directory.current.parent.path}");

    // read file projectDirectroy/pubspec.yaml
    final yamlFile =
        '${Directory.current.parent.path}/$projectDirectory/pubspec.yaml';
    final yaml = File(yamlFile).readAsStringSync();

    var doc = loadYaml(yaml);
    // write the updated yaml back to the file
    final jsonToMap = json.decode(json.encode(doc));
    jsonToMap['flutter']['assets'] = [
      'assets/images/',
      'assets/icons/',
      'assets/fonts/',
    ];

    final updatedYaml = json2yaml(jsonToMap);
    File(yamlFile).writeAsStringSync(updatedYaml);

    final String archDirectory = '${Directory.current.parent.path}/arch/lib';
    // copy the template/assets directory to the project directory
    final templateAssetsDirectory =
        Directory('$archDirectory/templates/assets');
    if (templateAssetsDirectory.existsSync()) {
      final destinationDirectory = Directory('$projectDirectory/');
      runCommand(
        'cp',
        [
          '-r',
          templateAssetsDirectory.path,
          destinationDirectory.path,
        ],
      );
    } else {
      print(
          'Template assets directory does not exist at ${templateAssetsDirectory.path}');
    }
  }
}
