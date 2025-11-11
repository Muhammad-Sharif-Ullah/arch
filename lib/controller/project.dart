import 'package:arch/arch.dart';
import 'package:arch/model/project_model.dart';
import 'package:arch/utils/create_assets.dart';
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
    // 'Development, Production, Staging',
    // 'Custom',
    'No Flavor',
  ];

  List<String> designPatterns = ["Clean Architecture"];
  List<String> apiClient = ['dio', 'http', 'chopper', 'retrofit'];

  List<String> navigationSelector = [
    // "Flutter Navigator 2.0",
    // "Auto Route",
    "Go Router",
  ];

  Future<void> call() async {
    // Get the project name
    final String projectName = Input(
      prompt: 'Enter the project name (snake case) ',
      defaultValue: 'my_project', // optional, will provide the user as a hint
      initialText: '', // optional, will be autofill in the input
      validator: (String x) {
        if (x.isEmpty) {
          throw ValidationError('Project name cannot be empty');
        }
        if (x.contains(' ')) {
          throw ValidationError('Project name cannot contain spaces');
        }
        if (x.contains(RegExp(r'[A-Z]'))) {
          throw ValidationError('Project name must be in snake case');
        }
        return true;
      },
    ).interact();

    // Get the project description
    final String projectDescription = Input(
      prompt: 'Enter the project description ',
      defaultValue: 'My awesome project',
      initialText: '',
      validator: (String x) {
        if (x.isEmpty) {
          throw ValidationError('Project description cannot be empty');
        }
        return true;
      },
    ).interact();

    // Get Author name could be empty
    final String authorName = Input(
      prompt: 'Enter the owner name ',
      defaultValue: 'https://www.owner.com',
      initialText: '',
      validator: (String x) {
        return true;
      },
    ).interact();

    // Get the project flavors
    // Options
    final selectionOfFlavor = Select(
      prompt: 'Select Project Flavors?',
      options: flavorOptions,
      initialIndex: 0,
    ).interact();

    if (selectionOfFlavor == 1) {
      final String customFlavor = Input(
        prompt: 'Enter the project flavors (comma separated) ',
        defaultValue: 'Dev, production, staging',
        initialText: '',
        validator: (String x) {
          if (x.isEmpty) {
            throw ValidationError('Project flavors cannot be empty');
          }
          return true;
        },
      ).interact();
      flavors =
          customFlavor.split(',').map((e) => e.trim().toLowerCase()).toList();
    } else if (selectionOfFlavor == 0) {
      flavors = ['dev', 'prod', 'stag'];
    } else {
      flavors = [];
    }

    // Get android package name
    final String androidPackageName = Input(
      prompt: 'Enter the android bundle identifier ',
      defaultValue: 'com.my.project.app',
      initialText: '',
      validator: (String x) {
        if (x.isEmpty) {
          throw ValidationError('Android package name cannot be empty');
        } else if (x.contains(' ')) {
          throw ValidationError('Android package name cannot contain spaces');
        }
        return true;
      },
    ).interact();

    // Get ios package name
    final String iosPackageName = Input(
      prompt: 'Enter the ios bundle Id ',
      defaultValue: androidPackageName,
      initialText: '',
      validator: (String x) {
        if (x.isEmpty) {
          throw ValidationError('iOS package name cannot be empty');
        } else if (x.contains(' ')) {
          throw ValidationError('iOS package name cannot contain spaces');
        }
        return true;
      },
    ).interact();

    // Get Platforms to support (Android, iOS, Web, Windows, MacOS, Linux)
    final List<int> platformList = MultiSelect(
      prompt: 'Select platforms to support',
      options: platforms,
      defaults: [true, true, true, false, false, false],
    ).interact();
    // selected platforms
    final List<String> selectedPlatforms = platformList
        .map((e) => platforms[e].toLowerCase())
        .toList(); // get the selected platforms

    // Get Design Pattern
    final int designPatternIndex = Select(
      prompt: 'Select Design Pattern',
      options: designPatterns,
      initialIndex: 0,
    ).interact();
    final String selectedDesignPattern = designPatterns[designPatternIndex];

    // get the navigation
    final int navigationIndex = Select(
      prompt: 'Select Navigation',
      options: navigationSelector,
      initialIndex: 0,
    ).interact();
    final String selectedNavigation = navigationSelector[navigationIndex];

    // get the api client
    final int apiClientIndex = Select(
      prompt: 'Select API Client',
      options: apiClient,
      initialIndex: 0,
    ).interact();
    final String selectedApiClient = apiClient[apiClientIndex];

    // Get License
    final int licenseIndex = Select(
      prompt: 'Select License',
      options: license,
      initialIndex: 0,
    ).interact();
    final String selectedLicense = license[licenseIndex];

    // Print the project details
    Table table = Table();
    table.addRow(["Key Point", "Selective Information"]);
    table.addRow(['Name', projectName]);
    table.addRow(['Description', projectDescription]);
    table.addRow(['Author Name', authorName]);
    table.addRow(['Flavors', "* ${flavors.join('\n* ')}"]);
    table.addRow(['Android Package Name', androidPackageName]);
    table.addRow(['iOS Package Name', iosPackageName]);
    table.addRow(['Platforms', "* ${selectedPlatforms.join('\n* ')}"]);
    table.addRow(['Navigation', selectedNavigation]);
    table.addRow(['License', selectedLicense]);
    table.addRow(['Design Pattern', selectedDesignPattern]);
    table.addRow(['API Client', selectedApiClient]);
    table[0]
        .theme
        .setFontColor(Color.blue)
        .setTextAlign(TextAlign.center)
        .setFontStyle({FontStyle.bold})
        .setBorderTop("=")
        .setBorderBottom("=")
        .setPaddingTop(1)
        .setPaddingBottom(1);

    for (var row in table) {
      if (row[0].getText() != "Key") {
        row[0].theme.setFontColor(Color.yellow).setTextAlign(TextAlign.left);
        row[1].theme.setFontColor(Color.green).setTextAlign(TextAlign.left);
      }
    }

    // print the table
    print(table);
    final ProjectModel projectModel = ProjectModel(
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

    String projectDirectory = '../${projectModel.projectName}';
    // final cmdAddToPubDevChangeAndroidPackage =
    //     "pub add --dev change_app_package_name";
    // final String cmdChangeAndroidPackageName =
    //     "run change_app_package_name:main ${projectModel.androidPackageName}";
    // execute the command

    try {
      await runCommand(
        'flutter',
        [
          'create',
          projectDirectory,
          '--description',
          projectModel.projectDescription,
          '--org',
          projectModel.androidPackageName,
          '--platforms=${projectModel.platforms.join(",")}',
          // '--android-language',
          // 'kotlin',
          // '--ios-language',
          // 'swift'
        ],
      );

      /// Change the directory to the project directory
      Directory.current = projectDirectory;

      /// Add the change_app_package_name package
      await runCommand(
          'flutter', ['pub', 'add', '--dev', 'change_app_package_name']);
      await runCommand("flutter", ["pub", "get"]);

      /// Change the package name
      await runCommand('dart', [
        'pub',
        'run',
        'change_app_package_name:main',
        projectModel.androidPackageName
      ]);

      /// remove the change_app_package_name package
      await runCommand(
        'flutter',
        [
          'pub',
          'remove',
          'change_app_package_name',
        ],
      );

      /// Add the dio package
      await runCommand('flutter', [
        'pub',
        'add',
        'dio',
        'flutter_bloc',
        'get_it',
        'cached_network_image',
        'in_app_update',
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

      /// Add the dev package
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
        'change_app_package_name',
      ]);

      ///TODO: generate license file

      /// TODO: generate the project structure

      /// check has any flavors
      // if (flavors.isNotEmpty) {
      //   //! TODO: check if host machine has rubbuy installed
      //   // final cmdInstallFlavorizr = "gem install flavorizr";
      //   await FlavorController.init(project: projectModel);
      // }

      /// create a project yaml file
      await ProjectYaml().writeProjectConfig(project: projectModel);

      // await AppIconReplace.exe(projectModel.platforms);

      // pwd

      /// Add Assets files in the project
      CreateAssets.createAssets(projectDirectory: projectModel.projectName);

      await runCommand('flutter', [
        'pub',
        'global',
        'activate',
        'flutter_launcher_icons',
      ]);

      await runCommand('dart', [
        'run',
        'flutter_launcher_icons',
        '-f',
        'flutter_launcher_icons.yaml',
      ]);

      final templatesRoot = p.normalize(
        p.join(Directory.current.parent.path, 'code/arch/lib/templates'),
      );
      print("template root - #$templatesRoot");

      final destRoot = p.join(Directory.current.path);
      print('dest root - 3$destRoot');
      await LibFolderTemplating.renderTemplatesFolder(
        templatesRoot: templatesRoot,
        srcFolder:
            'lib', // render everything that lives under templatesRoot/lib
        destRoot: destRoot,
        globals: {
          'project_name': projectName,
          'year': DateTime.now().year,
        },
      );

      await LibFolderTemplating.renderTemplatesFolder(
        templatesRoot: templatesRoot,
        srcFolder:
            '.vscode', // render everything that lives under templatesRoot/lib
        destRoot: '.',
        globals: {
          'project_name': projectName,
          'year': DateTime.now().year,
        },
      );
      final String archDirectory =
          '${Directory.current.parent.path}/code/arch/lib';

      /// other folder copy and paste
      runCommand(
        'cp',
        [
          Directory('$archDirectory/templates/l10n.yaml')
              .path, // 👈 Copy contents only
          '.', // 👈 Ensure assets folder exists
        ],
      );

      /// update localization
      LocalizationUtil.readProjectYAML(projectName);

      await runCommand('dart', [
        'pub',
        'global',
        'activate',
        'flutter_gen',
      ]);
      await runCommand('fluttergen', []);
      await runCommand('dart', [
        'run',
        'build_runner',
        'build',
        '--delete-conflicting-outputs',
      ]);
      await runCommand('rm', [
        'lib/main.dart',
      ]);
      print(
          "\n\nYour project has been created at  `${Directory.current.absolute}`");
      await runCommand('cd', [
        (Directory.current.absolute.path),
      ]);
      await runCommand('flutter', ['run', '-t', 'lib/main_development.dart']);
      // back to the root directory

      print("current directory ${Directory.current.absolute}");
    } catch (e) {
      print('An error occurred: $e');
    }
  }
}
