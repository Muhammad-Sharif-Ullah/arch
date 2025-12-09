import 'dart:io';

import 'package:arch_cli/utils/dart_fix.dart';
import 'package:arch_cli/utils/module_templating.dart';
import 'package:change_case/change_case.dart';
import 'package:dart_tabulate/dart_tabulate.dart';
import 'package:interact/interact.dart'
    show Confirm, Input, Select, ValidationError;
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class CreateModuleController {
  final List<String> stateManagementOptions = [
    'BloC',
    'Cubit',
    'HydratedBloc',
    'HydratedCubit',
    'None'
  ];

  Future<void> call() async {
    // ────────────────────────────────
    // 1️⃣ Collect input from user
    // ────────────────────────────────
    final String moduleName = Input(
      prompt: 'Enter the module name (snake_case): ',
      defaultValue: 'auth',
      validator: (String x) {
        if (x.isEmpty) throw ValidationError('Module name cannot be empty');
        if (x.contains(' ')) {
          throw ValidationError('Module name cannot contain spaces');
        }
        if (x.contains(RegExp(r'[A-Z]'))) {
          throw ValidationError('Module name must be snake_case');
        }
        return true;
      },
    ).interact();

    final int stateManagementIndex = Select(
      prompt: 'Select State Management:',
      options: stateManagementOptions,
      initialIndex: 0,
    ).interact();

    final bool needPage = Confirm(
      prompt: 'Do you need a page?',
      defaultValue: true,
    ).interact();

    String? pageName;
    if (needPage) {
      pageName = Input(
        prompt: 'Enter page name:',
        defaultValue: moduleName,
        validator: (String x) {
          if (x.isEmpty) throw ValidationError('Page name cannot be empty');
          if (x.contains(' ')) {
            throw ValidationError('Page name cannot contain spaces');
          }
          return true;
        },
      ).interact();
    }

    // ────────────────────────────────
    // 2️⃣ Display summary
    // ────────────────────────────────
    final table = Table()
      ..addRow(["Key", "Value"])
      ..addRow(['Module Name', moduleName])
      ..addRow(
          ['State Management', stateManagementOptions[stateManagementIndex]])
      ..addRow(['Need Page', needPage ? 'Yes' : 'No']);
    if (needPage) table.addRow(['Page Name', pageName!]);

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
    print(table);

    // ────────────────────────────────
    // 3️⃣ Validate project directory
    // ────────────────────────────────
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      print('\n❌ pubspec.yaml not found in your project directory.');
      print(
          '👉 Please run this command inside a valid Flutter/Dart project.\n');
      return;
    }

    final yamlString = await pubspecFile.readAsString();
    final doc = loadYaml(yamlString);
    final projectName = doc['name']?.toString() ?? 'unknown_project';

    // ────────────────────────────────
    // 4️⃣ Dynamically detect templates root
    // ────────────────────────────────
    // Determine the directory of the current CLI executable or source file
    final scriptDir = p.dirname(Platform.script.toFilePath());
    // Assuming templates are located at: <cli_package_root>/lib/templates
    // Go up until we find "lib/templates"
    final possibleTemplatePath = p.normalize(
      p.join(scriptDir, '..', 'lib', 'templates'),
    );

    final templatesRoot = Directory(possibleTemplatePath).existsSync()
        ? possibleTemplatePath
        : p.join(Directory.current.path, 'templates'); // fallback

    print('📂 Using templates from: $templatesRoot');

    // ────────────────────────────────
    // 5️⃣ Generate module
    // ────────────────────────────────
    await ModuleTemplating.renderTemplatesFolder(
      templatesRoot: templatesRoot,
      srcFolder: 'modules/',
      destRoot: './lib/features/',
      globals: {
        'module_name': moduleName,
        'page_name': pageName?.toPascalCase(),
        'class_name': moduleName.toPascalCase(),
        'project_name': projectName,
      },
    );
    DartFix.fixer();

    print('\n✅ Module "$moduleName" generated successfully!\n');
  }
}
