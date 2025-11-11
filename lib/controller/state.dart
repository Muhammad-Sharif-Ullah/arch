import 'dart:io';
import 'package:arch/templates/state/bloc_template.dart';
import 'package:arch/templates/state/cubit_template.dart';
import 'package:arch/templates/state/hydrated_bloc_template.dart';
import 'package:arch/templates/state/hydrated_cubit_template.dart';
import 'package:interact/interact.dart' show Input, Select, ValidationError;
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as p;

class StateController {
  static final List<String> _stateManagementOptions = [
    'BloC',
    'Cubit',
    'HydratedBloc',
    'HydratedCubit',
    'None'
  ];

  Future<void> call({required String moduleName}) async {
    final int stateManagementIndex = Select(
      prompt: 'Select State Management:',
      options: _stateManagementOptions,
      initialIndex: 0,
    ).interact();

    final String selected = _stateManagementOptions[stateManagementIndex];

    if (selected == 'None') {
      print('❌ Skipped: No state management selected.');
      return;
    }

    final String stateName = Input(
      prompt: 'Enter the State Name (snake_case): ',
      defaultValue: 'auth',
      validator: (String x) {
        if (x.isEmpty) throw ValidationError('State Name cannot be empty');
        if (x.contains(' ')) {
          throw ValidationError('State Name cannot contain spaces');
        }
        if (x.contains(RegExp(r'[A-Z]'))) {
          throw ValidationError('State Name must be snake_case');
        }
        return true;
      },
    ).interact();

    final File pubspec = File('pubspec.yaml');
    if (!pubspec.existsSync()) {
      print(
          '⚠️  No pubspec.yaml found. Please run this inside a Flutter project.');
      return;
    }

    final yamlMap = loadYaml(pubspec.readAsStringSync());
    final String? projectName = yamlMap['name'];
    if (projectName == null) {
      print('⚠️  Could not determine project name from pubspec.yaml');
      return;
    }

    final featurePath = p.join('lib', 'feature', moduleName);
    if (!Directory(featurePath).existsSync()) {
      print('⚠️  Module "$moduleName" not found under lib/feature/');
      return;
    }

    final isCubitType = selected.contains('Cubit');
    final folderName = isCubitType ? 'cubit' : 'bloc';
    final targetPath = p.join(featurePath, 'presentation', folderName);
    Directory(targetPath).createSync(recursive: true);

    switch (selected) {
      case 'BloC':
        await BlocTemplate.create(targetPath, stateName);
        break;
      case 'Cubit':
        await CubitTemplate.create(targetPath, stateName);
        break;
      case 'HydratedBloc':
        await HydratedBlocTemplate.create(targetPath, stateName);
        break;
      case 'HydratedCubit':
        await HydratedCubitTemplate.create(targetPath, stateName);
        break;
    }

    print('✅ $selected successfully created under $targetPath');
  }
}
