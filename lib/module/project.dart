import 'package:arch/arch.dart';
import 'package:arch/model/project_model.dart';
import 'package:arch/utils/command.dart';
import 'package:dart_tabulate/dart_tabulate.dart';
import 'package:interact/interact.dart'
    show Input, MultiSelect, Select, ValidationError;
import 'package:process_run/stdio.dart';

class CreateProjectController {
  List<String> flavors = ['dev, prod, stag'];
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
    'Development, Production, Staging',
    'Custom',
    'No Flavor',
  ];

  List<String> designPatterns = [
    "Clean Architecture",
    "MVC",
    "MVP",
    "MVVM",
  ];
  List<String> apiClient = ['dio', 'http', 'chopper', 'retrofit'];

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
      prompt: 'Enter the author name ',
      defaultValue: 'https://www.author.com',
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
      prompt: 'Enter the android package name ',
      defaultValue: 'com.my_project.app',
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
      prompt: 'Enter the ios package name ',
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
          '--android-language',
          'kotlin',
          '--ios-language',
          'swift'
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
      await runCommand('flutter', ['pub', 'add', 'dio']);

      ///TODO: generate license file

      /// TODO: generate the project structure

      /// check has any flavors
      if (flavors.isNotEmpty) {
        //! TODO: check if host machine has rubbuy installed
        // final cmdInstallFlavorizr = "gem install flavorizr";
        await FlavorController().init(project: projectModel);
      }

      // back to the root directory
      Directory.current = "../";
    } catch (e) {
      print('An error occurred: $e');
    }
  }
}
