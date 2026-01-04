import 'dart:io';

import 'package:arch_cli/utils/command.dart';
import 'package:arch_cli/utils/dart_fix.dart';
import 'package:arch_cli/utils/module_templating.dart';
import 'package:arch_cli/utils/state_manage_templating.dart';
import 'package:arch_cli/utils/templates_manager.dart';
import 'package:change_case/change_case.dart';
import 'package:dart_tabulate/dart_tabulate.dart';
import 'package:interact/interact.dart'
    show Confirm, Input, Select, ValidationError;
import 'package:yaml/yaml.dart';

class CreateModuleController {
  final List<String> stateManagementOptions = const [
    'BloC',
    'Cubit',
    'HydratedBloc',
    'HydratedCubit',
    'None',
  ];

  // ────────────────────────────────
  // PUBLIC ENTRY
  // ────────────────────────────────
  Future<void> call() async {
    final input = _collectInput();
    _printSummary(input);

    final projectName = await _validateProject();
    final templatesRoot = await TemplatesManager.getTemplatesRoot();

    await _generateModule(
      input: input,
      projectName: projectName,
      templatesRoot: templatesRoot,
    );

    if (input.stateManagement != 'None') {
      final sm = input.stateManagement;

      if (sm == 'HydratedBloc') {
        await StateManageTemplating.addHydratedBlocToLocator(
          input.moduleName,
          projectName,
        );
      } else if (sm == 'HydratedCubit') {
        await StateManageTemplating.addHydratedCubitToLocator(
          input.moduleName,
          projectName,
        );
      } else if (sm == 'BloC') {
        await StateManageTemplating.addBlocToLocator(
          input.moduleName,
          projectName,
        );
      } else if (sm == 'Cubit') {
        await StateManageTemplating.addCubitToLocator(
          input.moduleName,
          projectName,
        );
      }
    }

    await _updateRoutes(input, projectName);
    await _updateBarrel(input, projectName);
    await _updateLocator(input, projectName);

    await _runBuild();

    print('\n✅ Module "${input.moduleName}" generated successfully!\n');
  }

  // ────────────────────────────────
  // INPUT
  // ────────────────────────────────
  _InputData _collectInput() {
    final moduleName = Input(
      prompt: 'Enter module name (snake_case):',
      defaultValue: 'auth',
      validator: (x) {
        if (x.isEmpty) throw ValidationError('Cannot be empty');
        if (x.contains(' ') || x.contains(RegExp(r'[A-Z]'))) {
          throw ValidationError('Must be snake_case');
        }
        return true;
      },
    ).interact();

    final stateIndex = Select(
      prompt: 'Select State Management:',
      options: stateManagementOptions,
    ).interact();

    final needPage = Confirm(
      prompt: 'Do you need a page?',
      defaultValue: true,
    ).interact();

    final pageName = needPage
        ? Input(
            prompt: 'Enter page name:',
            defaultValue: moduleName,
            validator: (x) {
              if (x.isEmpty) throw ValidationError('Cannot be empty');
              return true;
            },
          ).interact()
        : null;

    return _InputData(
      moduleName: moduleName,
      pageName: pageName,
      needPage: needPage,
      stateManagement: stateManagementOptions[stateIndex],
    );
  }

  // ────────────────────────────────
  // SUMMARY
  // ────────────────────────────────
  void _printSummary(_InputData input) {
    final table = Table()
      ..addRow(['Key', 'Value'])
      ..addRow(['Module', input.moduleName])
      ..addRow(['State', input.stateManagement])
      ..addRow(['Need Page', input.needPage ? 'Yes' : 'No']);

    if (input.needPage) {
      table.addRow(['Page', input.pageName!]);
    }

    print(table);
  }

  // ────────────────────────────────
  // PROJECT VALIDATION
  // ────────────────────────────────
  Future<String> _validateProject() async {
    final pubspec = File('pubspec.yaml');
    if (!pubspec.existsSync()) {
      throw Exception('pubspec.yaml not found');
    }

    final yaml = loadYaml(await pubspec.readAsString());
    return yaml['name'];
  }

  // ────────────────────────────────
  // MODULE GENERATION
  // ────────────────────────────────
  Future<void> _generateModule({
    required _InputData input,
    required String projectName,
    required String templatesRoot,
  }) async {
    await ModuleTemplating.renderTemplatesFolder(
      templatesRoot: templatesRoot,
      srcFolder: 'modules/',
      destRoot: './lib/features/',
      globals: {
        'module_name': input.moduleName,
        'class_name': input.className,
        'page_name': input.pageClass,
        'project_name': projectName,
        'state_management': input.stateManagement,
      },
    );
  }

  // ────────────────────────────────
  // ROUTES
  // ────────────────────────────────
  Future<void> _updateRoutes(_InputData input, String projectName) async {
    final file = File('lib/app/router/routes.dart');
    String content = await file.readAsString();

    final routeClass = '${input.className}Route';

    content = content.replaceAll(
      RegExp(r'@TypedGoRoute<' + routeClass + r'>[\s\S]*?\}\n'),
      '',
    );

    content += '''

@TypedGoRoute<$routeClass>(
  path: ${input.pageClass}.path,
  name: ${input.pageClass}.name,
)
class $routeClass extends GoRouteData with \$$routeClass {
  const $routeClass();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ${input.pageClass}();
}
''';

    await file.writeAsString(content);
  }

  // ────────────────────────────────
  // BARREL EXPORT
  // ────────────────────────────────
  Future<void> _updateBarrel(_InputData input, String projectName) async {
    if (!input.needPage) return;

    final file = File('lib/app/router/barrel.dart');
    String content = await file.readAsString();

    final exportLine =
        "export 'package:$projectName/features/${input.moduleName}/presentation/view/${input.moduleName}_page.dart';";

    if (!content.contains(exportLine)) {
      content += '\n$exportLine';
    }

    await file.writeAsString(content);
  }

  // ────────────────────────────────
  // LOCATOR (DI)
  // ────────────────────────────────
  Future<void> _updateLocator(_InputData input, String projectName) async {
    final file = File('lib/core/di/locator.dart');
    String content = await file.readAsString();

    content = _ensureImport(
      content,
      "import 'package:$projectName/features/${input.moduleName}/di/${input.moduleName}_di.dart';",
    );

    content = content.replaceAll(
      RegExp(r'\s+${input.className}Di\.register\([^\)]*\);\n?'),
      '',
    );

    final setupRegex = RegExp(
      r'static Future<void> setup\(\{required AppEnvironment environment\}\) async \{([\s\S]*?)\n\s*\}',
    );

    final match = setupRegex.firstMatch(content);
    if (match != null) {
      final body = match.group(1)!;
      final updatedBody =
          '$body\n    ${input.className}Di.register(instance, environment: environment);';

      content = content.replaceRange(
        match.start,
        match.end,
        '''
static Future<void> setup({required AppEnvironment environment}) async {$updatedBody
  }''',
      );
    }

    await file.writeAsString(content);
  }

  // ────────────────────────────────
  // BUILD
  // ────────────────────────────────
  Future<void> _runBuild() async {
    await runCommand('dart', [
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    ]);
    DartFix.fixer();
  }

  // ────────────────────────────────
  // HELPERS
  // ────────────────────────────────
  String _ensureImport(String content, String importLine) {
    if (content.contains(importLine)) return content;

    final imports = RegExp(r"^import\s+'.*?';", multiLine: true)
        .allMatches(content)
        .toList();

    if (imports.isEmpty) return '$importLine\n$content';

    return content.replaceRange(
      imports.last.end,
      imports.last.end,
      '\n$importLine',
    );
  }
}

// ────────────────────────────────
// DATA MODEL
// ────────────────────────────────
class _InputData {
  final String moduleName;
  final String? pageName;
  final bool needPage;
  final String stateManagement;

  _InputData({
    required this.moduleName,
    required this.pageName,
    required this.needPage,
    required this.stateManagement,
  });

  String get className => moduleName.toPascalCase();
  String get pageClass => (pageName ?? moduleName).toPascalCase() + 'Page';
}
