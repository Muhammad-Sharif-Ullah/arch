import 'dart:io';

import 'package:arch/utils/command.dart';

class AppIconReplace {
  AppIconReplace._();

  static exe(List<String> platforms) async {
    if (platforms.isEmpty) {
      print('Please provide at least one platform to replace the app icon.');
      print("Usage: replace_icon <platform1> <platform2> ...");
      return;
    }

    for (final platform in platforms) {
      switch (platform.toLowerCase()) {
        case 'android':

          /// replace android app icon from the templates/app_icons/android/res
          /// bash script to replace the app icon
          // Define absolute paths for source and destination directories
          print("Current Dir ${Directory.current.parent.path}");
          String sourceDirectory =
              '${Directory.current.parent.path}/arch/lib/templates/app_icons/android/res/';
          String destinationDirectory =
              '${Directory.current.path}/android/app/src/main/res/';

          // Check if source directory exists
          if (!Directory(sourceDirectory).existsSync()) {
            throw Exception(
                'Source directory does not exist: $sourceDirectory');
          }

          // Check if destination directory exists
          if (!Directory(destinationDirectory).existsSync()) {
            throw Exception(
                'Destination directory does not exist: $destinationDirectory');
          }

          // Run the copy command
          await runCommand(
            'bash',
            [
              '-c',
              'cp -r $sourceDirectory* $destinationDirectory',
            ],
          );
          break;
        case 'ios':
          print("Current Dir ${Directory.current.parent.path}");
          String iosSourceDirectory =
              '${Directory.current.parent.path}/arch/lib/templates/app_icons/ios/';
          String iosDestinationDirectory =
              '${Directory.current.path}/ios/Runner/Assets.xcassets/AppIcon.appiconset/';
          // Check if source directory exists
          if (!Directory(iosSourceDirectory).existsSync()) {
            throw Exception(
                'Source directory does not exist: $iosSourceDirectory');
          }
          // Check if destination directory exists
          if (!Directory(iosDestinationDirectory).existsSync()) {
            throw Exception(
                'Destination directory does not exist: $iosDestinationDirectory');
          }
          // remove all previous icons in the destination directory
          await runCommand(
            'bash',
            [
              '-c',
              'rm -rf $iosDestinationDirectory*',
            ],
          );
          // Run the copy command
          await runCommand(
            'bash',
            [
              '-c',
              'cp -r $iosSourceDirectory* $iosDestinationDirectory',
            ],
          );
          break;
        case 'web':
          String webSourceDirectory =
              '${Directory.current.parent.path}/arch/lib/templates/app_icons/web/';
          String webDestinationDirectory =
              '${Directory.current.path}/web/icons/';

          // Check if source directory exists
          if (!Directory(webSourceDirectory).existsSync()) {
            throw Exception(
                'Source directory does not exist: $webSourceDirectory');
          }
          // Check if destination directory exists
          if (!Directory(webDestinationDirectory).existsSync()) {
            throw Exception(
                'Destination directory does not exist: $webDestinationDirectory');
          }
          // remove all previous icons in the destination directory
          await runCommand(
            'bash',
            [
              '-c',
              'rm -rf $webDestinationDirectory*',
            ],
          );
          // Run the copy command
          await runCommand(
            'bash',
            [
              '-c',
              'cp -r $webSourceDirectory* $webDestinationDirectory',
            ],
          );
          // replace favicon.png from arch/lib/templates/app_icons/favicon.png in destination directory /web/
          await runCommand(
            'bash',
            [
              '-c',
              'cp ${Directory.current.parent.path}/arch/lib/templates/app_icons/favicon.png ${Directory.current.path}/web/favicon.png',
            ],
          );
          break;
        default:
          print('Unknown platform: $platform');
      }
    }
  }
}
