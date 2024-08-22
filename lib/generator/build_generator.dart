import 'package:arch/arch.dart';
import 'package:arch/generator/generator.dart';

class BuildGenerator extends BaseGenerator {
  final BuildController buildController;
  final FolderController folderController;
  BuildGenerator({
    required this.buildController,
    required this.folderController,
  });

  @override
  Future<void> call(List<String> arguments) async {
    final LogoGeneratorController logoGeneratorController =
        LogoGeneratorController();

    final length = arguments.length;
    if (length < 2) {
      colorMsg(
          'Please provide a subcommand `arch ${arguments[0]} <subcommand>`',
          'red');
      colorMsg("Try 'arch --help' for more information", 'yellow');
    } else {
      final String subCommand = arguments[1].toLowerCase();
      if (subCommand == 'folder') {
        // folderController.build();
        logoGeneratorController.generate(
          iconColor: "FFFFFF",
          backgroundColor: "32BA58",
        );
      } else {
        colorMsg('Invalid argument `${arguments[1]}`', 'red');
        colorMsg("Try 'arch --help' for more information", 'yellow');
      }
    }
  }
}
