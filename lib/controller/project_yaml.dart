import 'dart:convert';
import 'dart:io';

import 'package:arch/model/project_model.dart';
import 'package:arch/utils/read_file.dart';
import 'package:arch/utils/write_file.dart';
import 'package:json2yaml/json2yaml.dart';
import 'package:yaml/yaml.dart';

/// This `ProjectToml` class is used to read and write the `project.toml` file.
/// take the `ProjectModel` as a parameter and write the content to the `project.toml` file.
/// in project directory.
///
class ProjectYaml {
  Future<void> writeProjectConfig({
    required final ProjectModel project,
  }) async {
    Directory.current = "../${project.projectName}/";
    final data = {
      'projectName': project.projectName,
      'projectDescription': project.projectDescription,
      'authorName': project.authorName,
      'platforms': project.platforms,
      'license': project.license,
      'designPattern': project.designPattern,
      'apiClient': project.apiClient,
    };

    // find out flavorizr.yaml file in the project directory
    final yamlString = await readContent(path: 'flavorizr.yaml');

    // check if the file exists
    if (yamlString.isNotEmpty) {
      // convert yaml content to json
      final Map<String, dynamic> flavors =
          jsonDecode(jsonEncode(loadYaml(yamlString)['flavors']));
      List<Map<String, dynamic>> flavorDetails = [];
      for (MapEntry flavor in flavors.entries) {
        flavorDetails.add({
          'name': flavor.key,
          'platforms': project.platforms.map((platform) {
            return {
              'platform': platform,
              'applicationId': platform == 'android'
                  ? project.androidPackageName
                  : project.iosPackageName,
            };
          }).toList(),
        });
      }
      data['flavor'] = {
        'flavorList': project.customFlavor,
        'flavorDetails': flavorDetails,
      };
    }

    // Convert data to YAML format
    final yamlData = json2yaml(data);

    // save this data as json file in the project directory as project-config.yaml
    final projectConfigYamlPath = "project-config.yaml";
    await writeFile(path: projectConfigYamlPath, content: yamlData);
  }
}
