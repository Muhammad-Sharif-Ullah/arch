import 'package:arch/controller/build.dart';
import 'package:arch/controller/folder.dart';
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
    final length = arguments.length;
    if (length < 2) {
      print('Please provide a subcommand `arc ${arguments[0]} <subcommand>`');
      print("Try 'arch --help' for more information");
    } else {
      final String subCommand = arguments[1].toLowerCase();
      if (subCommand == 'folder') {
        folderController.build();
      } else {
        print('Invalid argument `${arguments[1]}`');
        print("Try 'arch --help' for more information");
      }
    }
  }
}
