import 'package:arch/model/project_model.dart';
import 'package:arch/utils/command.dart';
import 'package:cli_spin/cli_spin.dart';
import 'package:interact/interact.dart'
    show Input, MultiSelect, Select, Theme, ValidationError;
import 'package:dart_tabulate/dart_tabulate.dart';
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
    'BSD 3-Clause "New" or "Revised" License',
    'GNU General Public License (GPL)',
    'GNU Library or "Lesser" General Public License (LGPL)',
    'Mozilla Public License 2.0',
    'Common Development and Distribution License',
    'Eclipse Public License version 2.0',
    'Creative Commons Zero v1.0 Universal',
    'Creative Commons Attribution 4.0 International',
    'Creative Commons Attribution-ShareAlike 4.0 International',
    'Creative Commons Attribution NonCommercial 4.0 International',
    'Creative Commons Attribution NoDerivatives 4.0 International',
    'Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International',
    'Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International',
    'Generate Custom',
    'Unlicense',
  ];
  List<String> flavorOptions = ['Development, Production, Staging', 'Custom'];

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
      defaultValue: 'https//:www.author.com',
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
    } else {
      flavors = ['dev', 'prod', 'stag'];
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
      selectionOfFlavor:
          selectionOfFlavor == 0 ? 'Dev, Production, Staging' : 'Custom',
      customFlavor: flavors,
      designPattern: selectedDesignPattern,
      androidPackageName: androidPackageName,
      iosPackageName: iosPackageName,
      platforms: selectedPlatforms,
      license: selectedLicense,
      apiClient: selectedApiClient,
    );

    String projectDirectory = '../${projectModel.projectName}';
    final cmdAddToPubDevChangeAndroidPackage =
        "pub add --dev change_app_package_name";
    final String cmdChangeAndroidPackageName =
        "run change_app_package_name:main ${projectModel.androidPackageName}";
    // execute the command

    try {
      runCommand(
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
      Directory.current = projectDirectory;
      await runCommand(
        'flutter',
        cmdAddToPubDevChangeAndroidPackage.split(" "),
        spinnerRunning: "Adding change_app_package_name to pubspec.yaml...",
        spinnerDone: "change_app_package_name added to pubspec.yaml",
      );
      await runCommand(
        'dart',
        cmdChangeAndroidPackageName.split(" "),
        spinnerRunning: "Changing Android package name...",
        spinnerDone: "Android and IOS package name changed successfully",
      );
      Directory.current = "../";
    } catch (e) {
      print('An error occurred: $e');
    }
  }
}
