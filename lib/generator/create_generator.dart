import 'package:arch/controller/module.dart';
import 'package:arch/controller/project.dart';
import 'package:arch/controller/state.dart';
import 'package:arch/generator/generator.dart';

class CreateGenerator extends BaseGenerator {
  final CreateProjectController createProjectController;
  final CreateModuleController createModuleController;
  final StateController stateController;
  CreateGenerator({
    required this.createProjectController,
    required this.createModuleController,
    required this.stateController,
  });

  @override
  Future<void> call(List<String> arguments) async {
    if (arguments.length < 2) {
      print('Please provide a subcommand `arc ${arguments[0]} <subcommand>`');
      print("Try 'arch --help' for more information\n");
      print(
          "Try with these command \n1. `arch --create porject` to create new project");
      print('2. `arch --create module` to create new module');
    } else {
      final String subCommand = arguments[1].toLowerCase();
      if (subCommand == 'project') {
        createProjectController.call();
      } else if (subCommand == 'module') {
        createModuleController.call();
      } else if (subCommand == 'state') {
        stateController.call(moduleName: 'home');
      } else {
        print('Invalid argument `${arguments[1]}`');
        print("Try 'arch --help' for more information\n");
        print(
            "Try with these command \n1. `arch --create porject` to create new project");
        print('`2. arch --create module` to create new module');
      } // end of else
    }
  }
}
