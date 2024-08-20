import 'package:arch/model/project_model.dart';
import 'package:arch/utils/camel_case.dart';
import 'package:arch/utils/command.dart';
import 'package:arch/utils/read_file.dart';
import 'package:arch/utils/write_content.dart';
import 'package:mustache_template/mustache.dart';
import 'package:process_run/stdio.dart';

class FlavorController {
  Future<void> init({
    required final ProjectModel project,
  }) async {
    // print("PROJECT DIRECTORY ${project.projectName}");
    String projectDirectory = '../${project.projectName}';

    String appName = camelCase(project.projectName);
    String androidPackage = project.androidPackageName;
    String iosBundleId = project.iosPackageName;
    final flavors = project.customFlavor;
    final platforms = project.platforms;
    // check current directory

    Directory.current = "../arch/";
    // print("CURRENT DIRECTORY ${Directory.current.path}");

    final templateString =
        await readContent(path: 'lib/templates/flavorizr.text');
    final template = Template(templateString);

    final data = {
      'appName': appName,
      'androidPackage': androidPackage,
      'iosBundleId': iosBundleId,
      'flavors': flavors.map((flavor) {
        return {
          'name': flavor,
          'titleName': flavor[0].toUpperCase() + flavor.substring(1),
          'isNotProd': flavor != 'prod' && flavor != 'production',
          'platforms': platforms.map((platform) {
            return {
              'isAndroid': platform == 'android',
              'isIOS': platform == 'ios',
              'macos': platform == 'macos',
            };
          }).toList(),
        };
      }).toList(),
    };
    final result = template.renderString(data);
    /// copy from templates assets file to project directory
    await runCommand('cp', ['-r', 'lib/templates/assets', projectDirectory]);

    Directory.current = projectDirectory;
    // print("CURRENT DIRECTORY ${Directory.current.path}");

    // save this to a file called flavorizr.yaml
    await writeContent(
        path: '$projectDirectory/flavorizr.yaml', content: result);


    await runCommand('flutter', [
      'pub',
      'add',
      '--dev',
      'flutter_flavorizr',
    ]);

    // final rendered = content.render(
    //   {
    //     'app_name': appName,
    //     'android_package': androidPackage,
    //     'ios_bundle_id': iosBundleId,
    //     'flavors': flavors,
    //     'platforms': ['android', 'ios'],
    //   },
    // );
    // await writeContent('flavorizr.yaml', content);
    await runCommand('flutter', ['pub', 'get']);

    // generate flavor
    await runCommand('flutter', ['pub', 'run', 'flutter_flavorizr']);
  }
}
