import 'dart:io';

import 'package:arch_cli/arch.dart';
import 'package:arch_cli/model/project_model.dart';
import 'package:arch_cli/utils/dart_fix.dart';
import 'package:arch_cli/utils/lib_folder_templating.dart';
import 'package:arch_cli/utils/localization.dart';
import 'package:arch_cli/utils/project_logo_handler.dart';
import 'package:change_case/change_case.dart';
import 'package:dart_tabulate/dart_tabulate.dart';
import 'package:interact/interact.dart'
    show Input, MultiSelect, Select, ValidationError;
import 'package:path/path.dart' as p;
import 'package:process_run/stdio.dart';
import 'package:arch_cli/utils/templates_manager.dart';

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
    try {
      final project = _collectProjectInfo();
      _printSummary(project);

      await _createFlutterProject(project);
      await _setupDependencies(project);
      await ProjectYaml().writeProjectConfig(project: project);

      final templatesRoot = await TemplatesManager.getTemplatesRoot();
      final destRoot = p.join(Directory.current.path);
      await LibFolderTemplating.renderTemplatesFolder(
        templatesRoot: templatesRoot,
        srcFolder: 'project',
        destRoot: destRoot,
        globals: {
          'project_name': project.projectName,
          'project_name_capitalized':
              project.projectName.toCapitalCase().replaceAll(' ', ''),
          'year': DateTime.now().year,
          'ownner_url': project.authorName,
          'isAndroid': project.platforms.contains('android'),
          'isIOS': project.platforms.contains('ios'),
          'isWeb': project.platforms.contains('web'),
          'isLinux': project.platforms.contains('linux'),
          'isWindows': project.platforms.contains('windows'),
          'isMacOS': project.platforms.contains('macos'),
        },
      );

      await ProjectLogoHandler.handleProjectLogo(project);

      await runCommand(
          'flutter', ['pub', 'global', 'activate', 'flutter_launcher_icons']);
      await runCommand('dart', [
        'run',
        'flutter_launcher_icons',
        '-f',
        'flutter_launcher_icons.yaml'
      ]);

      LocalizationUtil.readProjectYAML(project.projectName);

      await runCommand('dart', ['pub', 'global', 'activate', 'flutter_gen']);
      await runCommand('fluttergen', []);
      await runCommand('dart',
          ['run', 'build_runner', 'build', '--delete-conflicting-outputs']);
      await runCommand('rm', ['lib/main.dart']);
      DartFix.fixer();
    } catch (e) {
      print('❌ Error: $e');
    } finally {
      TemplatesManager.cleanup();
    }
  }

  ProjectModel _collectProjectInfo() {
    final projectName = _input(
      'Enter project name (snake_case)',
      'my_project',
    ).toSnakeCase();

    final description = _input(
      'Enter project description',
      'My awesome project',
    );

    final author = _input(
      'Enter owner name / URL',
      'https://www.owner.com',
    );
    flavors = _selectFlavors();
    final androidPackage = _input(
      'Android bundle identifier',
      'com.my.project.app',
      _noSpaceValidator,
    );

    final iosPackage = _input(
      'iOS bundle identifier',
      androidPackage,
      _noSpaceValidator,
    );

    final selectedPlatforms = _selectPlatforms();
    final selectedDesignPattern =
        designPatterns[_select('Select design pattern', 0, designPatterns)];
    final String selectedNavigation = navigationSelector[
        _select('Select navigation package', 0, navigationSelector)];
    final String selectedApiClient =
        apiClient[_select('Select API client package', 0, apiClient)];
    final String selectedLicense =
        license[_select('Select project license', 0, license)];

    final logoPath = _collectLogoInput();

    return ProjectModel(
      projectName: projectName,
      projectDescription: description,
      authorName: author,
      customFlavor: flavors,
      designPattern: selectedDesignPattern,
      navigation: selectedNavigation,
      androidPackageName: androidPackage,
      iosPackageName: iosPackage,
      platforms: selectedPlatforms,
      license: selectedLicense,
      apiClient: selectedApiClient,
      logoPath: logoPath,
    );
  }

  String? _collectLogoInput() {
    String input = Input(
      prompt: 'Enter project logo (local path or URL, optional)',
      defaultValue: '',
    ).interact();

    if (input.trim().isEmpty) return null;
    // remove sigle and double quotes from input
    input = input.replaceAll('"', '').replaceAll("'", "");
    return input.trim();
  }

  String _input(String prompt, String defaultValue,
      [bool Function(String)? validator]) {
    return Input(
      prompt: prompt,
      defaultValue: defaultValue,
      validator: validator == null ? null : (v) => validator(v) ? true : false,
    ).interact();
  }

  int _select(String prompt, int defaultValue, List<String> options) {
    return Select(
      prompt: prompt,
      options: options,
      initialIndex: defaultValue,
    ).interact();
  }

  List<String> _selectFlavors() {
    final selectionOfFlavor = _select(
      'Select Project Flavors?',
      0,
      flavorOptions,
    );
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
    return flavors;
  }

  List<String> _selectPlatforms() {
    final selectedPlatforms = MultiSelect(
      prompt: 'Select target platforms',
      options: platforms,
      defaults: [true, true, true, false, false, false],
    ).interact();
    return selectedPlatforms.map((e) => platforms[e].toLowerCase()).toList();
  }

  bool _noSpaceValidator(String v) => !v.contains(' ');

  void _printSummary(ProjectModel project) {
    final table = Table()
      ..addRow(['Key', 'Value'])
      ..addRow(['Name', project.projectName])
      ..addRow(['Description', project.projectDescription])
      ..addRow(['Platforms', project.platforms.join(', ')])
      ..addRow(['Logo', project.logoPath ?? 'None'])
      ..addRow(['Design Pattern', project.designPattern])
      ..addRow(['Navigation', project.navigation])
      ..addRow(['API Client', project.apiClient])
      ..addRow(['Flavors', project.customFlavor.join(', ')])
      ..addRow(['Android Package', project.androidPackageName])
      ..addRow(['iOS Package', project.iosPackageName])
      ..addRow(['License', project.license]);

    print(table);
  }

  Future<void> _createFlutterProject(ProjectModel project) async {
    final projectDirectory = project.projectName;

    await runCommand('flutter', [
      'create',
      projectDirectory,
      '--description',
      project.projectDescription,
      '--org',
      project.androidPackageName,
      '--platforms=${project.platforms.join(",")}',
    ]);
  }

  Future<void> _setupDependencies(ProjectModel project) async {
    // check current directory
    print("Check current directory: ${Directory.current.path}");
    // check cli directory
    print("CLI directory: ${p.dirname(Platform.script.toFilePath())}");
    final String projectDirectory = './${project.projectName}';

    Directory.current = projectDirectory;

    await runCommand(
        'flutter', ['pub', 'add', '--dev', 'change_app_package_name']);
    await runCommand('flutter', ['pub', 'get']);
    await runCommand('dart', [
      'pub',
      'run',
      'change_app_package_name:main',
      project.androidPackageName
    ]);
    if (project.androidPackageName != project.iosPackageName) {
      await runCommand('dart', [
        'pub',
        'run',
        'change_app_package_name:main',
        project.iosPackageName,
        '--ios',
      ]);
    }
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
      'flutter_launcher_icons',
      'font_awesome_flutter'
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
  }
}
