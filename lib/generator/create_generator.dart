import 'package:arch/controller/project.dart';
import 'package:arch/generator/generator.dart';

class CreateGenerator extends BaseGenerator {
  final CreateProjectController createProjectController;
  CreateGenerator({
    required this.createProjectController,
  });

  @override
  Future<void> call(List<String> arguments) async {
    if (arguments.length < 2) {
      print('Please provide a subcommand `arc ${arguments[0]} <subcommand>`');
      print("Try 'arch --help' for more information");
    } else {
      final String subCommand = arguments[1].toLowerCase();
      if (subCommand == 'project') {
        createProjectController.call();
      } else if (subCommand == 'module') {
        print('Create module');
      } else {
        print('Invalid argument `${arguments[1]}`');
        print("Try 'arch --help' for more information");
      } // end of else
    }
  }
}
