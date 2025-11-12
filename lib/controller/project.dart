import 'dart:io';
import 'package:arch/arch.dart';
import 'package:arch/model/project_model.dart';
import 'package:arch/utils/create_assets.dart';
import 'package:arch/utils/dart_fix.dart';
import 'package:arch/utils/lib_folder_templating.dart';
import 'package:arch/utils/localization.dart';
import 'package:dart_tabulate/dart_tabulate.dart';
import 'package:interact/interact.dart'
    show Input, MultiSelect, Select, ValidationError;
import 'package:process_run/stdio.dart';
import 'package:path/path.dart' as p;

class CreateProjectController {
  List<String> flavors = ['development, production, staging'];
  List<String> platforms = [
    'Android',
    'iOS',
    'Web',
    'Windows',
    'MacOS',
    'Linux',
  ];
  List<String> license = [
    'Apache License 2.0',
    'MIT License',
    'BSD 2-Clause "Simplified" License',
    'Generate Custom',
    'Unlicense',
  ];
  List<String> flavorOptions = [
    'No Flavor',
  ];

  List<String> designPatterns = ["Clean Architecture"];
  List<String> apiClient = ['dio', 'http', 'chopper', 'retrofit'];

  List<String> navigationSelector = [
    "Go Router",
  ];

  Future<void> call() async {
    // --- Collect Inputs ---
    final String projectName = Input(
      prompt: 'Enter the project name (snake case) ',
      defaultValue: 'my_project',
      validator: (String x) {
        if (x.isEmpty) throw ValidationError('Project name cannot be empty');
        if (x.contains(' ')) {
          throw ValidationError('Project name cannot contain spaces');
        }
        if (x.contains(RegExp(r'[A-Z]'))) {
          throw ValidationError('Use snake_case only');
        }
        return true;
      },
    ).interact();

    final String projectDescription = Input(
      prompt: 'Enter the project description ',
      defaultValue: 'My awesome project',
      validator: (String x) =>
          x.isEmpty ? throw ValidationError('Description required') : true,
    ).interact();

    final String authorName = Input(
      prompt: 'Enter the owner name ',
      defaultValue: 'https://www.owner.com',
      validator: (String x) => true,
    ).interact();

    final selectionOfFlavor = Select(
      prompt: 'Select Project Flavors?',
      options: flavorOptions,
      initialIndex: 0,
    ).interact();

    if (selectionOfFlavor == 0) {
      flavors = ['dev', 'prod', 'stag'];
    } else {
      final String customFlavor = Input(
        prompt: 'Enter the project flavors (comma separated)',
        defaultValue: 'dev, production, staging',
        validator: (String x) {
          if (x.isEmpty) throw ValidationError('Flavors cannot be empty');
          return true;
        },
      ).interact();
      flavors =
          customFlavor.split(',').map((e) => e.trim().toLowerCase()).toList();
    }

    final String androidPackageName = Input(
      prompt: 'Enter the Android bundle identifier ',
      defaultValue: 'com.my.project.app',
      validator: (String x) {
        if (x.isEmpty) throw ValidationError('Package name required');
        if (x.contains(' ')) throw ValidationError('No spaces allowed');
        return true;
      },
    ).interact();

    final String iosPackageName = Input(
      prompt: 'Enter the iOS bundle Id ',
      defaultValue: androidPackageName,
      validator: (String x) {
        if (x.isEmpty) throw ValidationError('Bundle Id required');
        if (x.contains(' ')) throw ValidationError('No spaces allowed');
        return true;
      },
    ).interact();

    final List<int> platformList = MultiSelect(
      prompt: 'Select platforms to support',
      options: platforms,
      defaults: [true, true, true, false, false, false],
    ).interact();
    final List<String> selectedPlatforms =
        platformList.map((e) => platforms[e].toLowerCase()).toList();

    final String selectedDesignPattern = designPatterns[Select(
            prompt: 'Select Design Pattern',
            options: designPatterns,
            initialIndex: 0)
        .interact()];

    final String selectedNavigation = navigationSelector[Select(
            prompt: 'Select Navigation',
            options: navigationSelector,
            initialIndex: 0)
        .interact()];

    final String selectedApiClient = apiClient[
        Select(prompt: 'Select API Client', options: apiClient, initialIndex: 0)
            .interact()];

    final String selectedLicense = license[
        Select(prompt: 'Select License', options: license, initialIndex: 0)
            .interact()];

    // --- Display Summary Table ---
    Table table = Table();
    table.addRow(["Key", "Information"]);
    table.addRow(['Name', projectName]);
    table.addRow(['Description', projectDescription]);
    table.addRow(['Author', authorName]);
    table.addRow(['Flavors', "* ${flavors.join('\n* ')}"]);
    table.addRow(['Android Package', androidPackageName]);
    table.addRow(['iOS Package', iosPackageName]);
    table.addRow(['Platforms', "* ${selectedPlatforms.join('\n* ')}"]);
    table.addRow(['Navigation', selectedNavigation]);
    table.addRow(['License', selectedLicense]);
    table.addRow(['Architecture', selectedDesignPattern]);
    table.addRow(['API Client', selectedApiClient]);
    print(table);

    final projectModel = ProjectModel(
      projectName: projectName,
      projectDescription: projectDescription,
      authorName: authorName,
      customFlavor: flavors,
      designPattern: selectedDesignPattern,
      navigation: selectedNavigation,
      androidPackageName: androidPackageName,
      iosPackageName: iosPackageName,
      platforms: selectedPlatforms,
      license: selectedLicense,
      apiClient: selectedApiClient,
    );

    final String projectDirectory = '../${projectModel.projectName}';

    try {
      // --- Flutter Project Creation ---
      await runCommand('flutter', [
        'create',
        projectDirectory,
        '--description',
        projectModel.projectDescription,
        '--org',
        projectModel.androidPackageName,
        '--platforms=${projectModel.platforms.join(",")}',
      ]);

      Directory.current = projectDirectory;

      await runCommand(
          'flutter', ['pub', 'add', '--dev', 'change_app_package_name']);
      await runCommand('flutter', ['pub', 'get']);
      await runCommand('dart', [
        'pub',
        'run',
        'change_app_package_name:main',
        projectModel.androidPackageName
      ]);
      await runCommand('flutter', ['pub', 'remove', 'change_app_package_name']);

      // --- Dependencies ---
      await runCommand('flutter', [
        'pub',
        'add',
        'dio',
        'flutter_bloc',
        'get_it',
        'cached_network_image',
        'flutter_animate',
        'google_fonts',
        'go_router',
        'hydrated_bloc',
        'change_case',
        'intl',
        'equatable',
        'package_info_plus',
        'url_launcher',
        'collection',
        'json_annotation',
        'envied',
        'uuid',
        'logger',
        'pretty_dio_logger',
        'dio_smart_retry',
        'device_info_plus',
        'flutter_svg',
        'path_provider',
        'flutter_gen',
        'flutter_launcher_icons'
      ]);

      await runCommand('flutter', [
        'pub',
        'add',
        '-d',
        'build_runner',
        'json_serializable',
        'retrofit_generator',
        'envied_generator',
        'go_router_builder',
        'very_good_analysis',
        'build_verify',
      ]);

      await ProjectYaml().writeProjectConfig(project: projectModel);
      CreateAssets.createAssets(projectDirectory: projectModel.projectName);

      await runCommand(
          'flutter', ['pub', 'global', 'activate', 'flutter_launcher_icons']);
      await runCommand('dart', [
        'run',
        'flutter_launcher_icons',
        '-f',
        'flutter_launcher_icons.yaml'
      ]);

      // --- Render Templates ---
      final templatesRoot = p.normalize(
          p.join(Directory.current.parent.path, 'code/arch/lib/templates'));
      final destRoot = p.join(Directory.current.path);

      await LibFolderTemplating.renderTemplatesFolder(
        templatesRoot: templatesRoot,
        srcFolder: 'lib',
        destRoot: destRoot,
        globals: {'project_name': projectName, 'year': DateTime.now().year},
      );

      await _fixFeatureStructure(
          Directory.current.path); // 👈 Auto-remove modules

      await LibFolderTemplating.renderTemplatesFolder(
        templatesRoot: templatesRoot,
        srcFolder: '.vscode',
        destRoot: '.',
        globals: {'project_name': projectName, 'year': DateTime.now().year},
      );

      LocalizationUtil.readProjectYAML(projectName);

      await runCommand('dart', ['pub', 'global', 'activate', 'flutter_gen']);
      await runCommand('fluttergen', []);
      await runCommand('dart',
          ['run', 'build_runner', 'build', '--delete-conflicting-outputs']);
      await runCommand('rm', ['lib/main.dart']);

      print(
          '\n✅ Project successfully created at: ${Directory.current.absolute.path}\n');
      await runCommand('flutter', ['run', '-t', 'lib/main_development.dart']);

      DartFix.fixer();
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  /// 🔧 Fixes folder structure by removing `modules` from inside `features`
  Future<void> _fixFeatureStructure(String projectDirectory) async {
    final modulesDir = Directory('$projectDirectory/lib/features/modules');
    final featuresDir = Directory('$projectDirectory/lib/features');

    if (await modulesDir.exists()) {
      final entities = modulesDir.listSync();
      for (final entity in entities) {
        if (entity is Directory) {
          final moduleName = p.basename(entity.path);
          final newPath = p.join(featuresDir.path, moduleName);
          if (!await Directory(newPath).exists()) {
            await entity.rename(newPath);
            print('✅ Moved module: $moduleName');
          }
        }
      }
      await modulesDir.delete(recursive: true);
      print('🧹 Removed old "modules" folder.');
    }
  }
}
