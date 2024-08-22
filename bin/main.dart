import 'package:arch/arch.dart';

/// Controller
final CreateProjectController createProjectController =
    CreateProjectController();
final HelpController helpController = HelpController();
final WelcomeBanner welcomeBanner = WelcomeBanner();
final FlavorController flavorController = FlavorController();
final BuildController buildController = BuildController();
final FolderController folderController = FolderController();

/// Generator
final CreateGenerator createGenerator = CreateGenerator(
  createProjectController: createProjectController,
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
  if (arguments.isEmpty) {
    welcomeBanner.call();
    colorMsg('Please provide a command' '\n', 'red');
    colorMsg(
        "In order to use the CLI, you need to provide arguments", 'yellow');
    colorMsg("Try 'arch --help' for more information", 'yellow');
  } else {
    final String initialCommand = arguments[0].toLowerCase();
    welcomeBanner.call();
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
