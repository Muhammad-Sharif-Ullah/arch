import 'package:arch_cli/arch.dart';
import 'package:arch_cli/controller/model.dart';
import 'package:arch_cli/controller/model_entity_generator.dart';
import 'package:arch_cli/controller/module.dart';
import 'package:arch_cli/controller/state.dart';

/// Controller
final CreateProjectController createProjectController =
    CreateProjectController();
final HelpController helpController = HelpController();
final WelcomeBanner welcomeBanner = WelcomeBanner();
final FlavorController flavorController = FlavorController();
final BuildController buildController = BuildController();
final FolderController folderController = FolderController();
final CreateModuleController createModuleController = CreateModuleController();
final StateController stateController = StateController();
final ModelController modelController = ModelController();
final EntityModelController entityModelController = EntityModelController();

/// Generator
final CreateGenerator createGenerator = CreateGenerator(
  createProjectController: createProjectController,
  createModuleController: createModuleController,
  stateController: stateController,
  modelController: modelController,
  entityModelController: entityModelController,
);
final BuildGenerator buildGenerator = BuildGenerator(
  buildController: buildController,
  folderController: FolderController(),
);

void main(List<String> arguments) {
  // return;
  // possible command line arguments
  // 1. arch --help
  // 2. arch --version
  // 3. arch --create
  // 4. arch --update
  // 5. arch --delete
  // 6. arch --generate
  // 7. arch --create project
  // check arguments
  welcomeBanner.call();
  if (arguments.isEmpty) {
    colorMsg('Please provide a command' '\n', 'red');
    colorMsg(
        "In order to use the CLI, you need to provide arguments", 'yellow');
    colorMsg("Try 'arch --help' for more information", 'yellow');
  } else {
    final String initialCommand = arguments[0].toLowerCase();
    // welcomeBanner.call();
    switch (initialCommand) {
      case "--help":
        helpController.call();
        break;
      case "--version":
        print('Version 1.0.0');
        break;
      case "--create":
        createGenerator.call(arguments);
        break;
      case "--update":
        print('Update');
        break;
      case "--delete":
        print('Delete');
        break;
      case "--build":
        buildGenerator.call(arguments);
        break;
      default:
        colorMsg('Invalid argument' '\n', 'red');
        colorMsg("Try 'arch --help' for more information" '\n', 'yellow');
    }
  }
}
