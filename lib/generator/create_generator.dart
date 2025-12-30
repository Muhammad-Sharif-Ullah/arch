import 'package:arch_cli/controller/model.dart';
import 'package:arch_cli/controller/model_entity_generator.dart';
import 'package:arch_cli/controller/module.dart';
import 'package:arch_cli/controller/project_test.dart';
import 'package:arch_cli/controller/state.dart';
import 'package:arch_cli/generator/generator.dart';

class CreateGenerator extends BaseGenerator {
  final TestCreateProjectController createProjectController;
  final CreateModuleController createModuleController;
  final StateController stateController;
  final ModelController modelController;
  final EntityModelController entityModelController;

  CreateGenerator({
    required this.createProjectController,
    required this.createModuleController,
    required this.stateController,
    required this.modelController,
    required this.entityModelController,
  });

  @override
  Future<void> call(List<String> arguments) async {
    if (arguments.length < 2) {
      _printUsage();
      return;
    }

    final String subCommand = arguments[1].toLowerCase();

    switch (subCommand) {
      case 'project':
        createProjectController.call();
      case 'module':
        createModuleController.call();
      case 'state':
      case 'model':
      case 'model-entity':
        _handleModuleScopedCommand(subCommand, arguments);
      default:
        print("❌ Invalid subcommand: '$subCommand'");
        _printUsage();
    }
  }

  void _handleModuleScopedCommand(String subCommand, List<String> args) {
    // Expecting format: `arch --create <subCommand> on <module-name>`
    if (args.length < 4 || args[2] != 'on') {
      print("❌ Invalid syntax for '$subCommand'.");
      print("💡 Expected: arch --create $subCommand on <module-name>");
      print("Example: arch --create $subCommand on home");
      return;
    }

    final moduleName = args[3].trim();
    if (moduleName.isEmpty) {
      print("❌ Missing module name.");
      print("💡 Example: arch --create $subCommand on home");
      return;
    }

    try {
      switch (subCommand) {
        case 'state':
          stateController.call(moduleName: moduleName);
        case 'model':
          modelController.call(moduleName: moduleName);
        case 'model-entity':
          entityModelController.call(moduleName: moduleName);
      }
    } catch (e, _) {
      print(
          "💥 Error while executing '$subCommand' for module '$moduleName': $e");
      // Optionally print stack trace in debug mode
      // print(st);
    }
  }

  void _printUsage() {
    print('''
Usage: arch --create <subcommand> [options]

Available subcommands:
  project                Create a new project
  module                 Create a new module
  state on <module>      Create state in specified module
  model on <module>      Create model in specified module
  model-entity on <module>  Create entity model in specified module

Examples:
  arch --create project
  arch --create module
  arch --create state on home
  arch --create model on user
  arch --create model-entity on product
''');
  }
}
