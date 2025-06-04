import 'package:arch/arch.dart';
import 'package:arch/model/project_model.dart';
import 'package:arch/utils/generate_file_and_folder.dart';
import 'package:jinja/jinja.dart';
import 'package:jinja/loaders.dart';

class FolderController {
  Future<void> build() async {
    final ProjectModel projectModel = ProjectModel(
      projectName: "news_cafe",
      projectDescription: "A Flutter News Application",
      authorName: "https://www.piistech.com",
      customFlavor: ['dev', 'prod', 'stag'],
      designPattern: 'Clean Architecture',
      apiClient: 'dio',
      androidPackageName: "com.piistech.news_cafe.app",
      iosPackageName: "com.piistech.news_cafe.app",
      platforms: ["android", "ios", "web"],
      license: "MIT",
      navigation: "Flutter Navigator 2.0",
    );
    final String rootTemplateDirectory = 'lib/templates/lib';
    final String outputTemplateDirectory = "generated";
    var loader = FileSystemLoader(
      paths: [rootTemplateDirectory],
    );

    var env = Environment(
      autoReload: true,
      loader: loader,
      leftStripBlocks: true,
      trimBlocks: true,
    );

    var template = env.getTemplate('flavor.dart');
    final output = template.render({
      "flavors": projectModel.customFlavor,
      "flavorsTitle":
          projectModel.customFlavor.map((e) => e.toLowerCase()).toList(),
    });
    await generateFileAndFolder(
        filePath: "$outputTemplateDirectory/flavor.dart", content: output);
  }
}
