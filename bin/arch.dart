import 'package:arch/arch.dart' as arch;

/// Controller
final arch.CreateProjectController createProjectController =
    arch.CreateProjectController();
final arch.HelpController helpController = arch.HelpController();
final arch.WelcomeBanner welcomeBanner = arch.WelcomeBanner();
final arch.FlavorController flavorController = arch.FlavorController();
final arch.BuildController buildController = arch.BuildController();

/// Generator
final arch.CreateGenerator createGenerator = arch.CreateGenerator(
  createProjectController: createProjectController,
);
final arch.BuildGenerator buildGenerator = arch.BuildGenerator(
  controller: buildController,
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
    print('Please provide a command');
    print("In order to use the CLI, you need to provide arguments");
    print("Try 'arch --help' for more information");
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
        
        break;
      default:
        print('Invalid argument');
        print("Try 'arch --help' for more information");
    }
  }
}
