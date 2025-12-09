import 'dart:io';
import 'package:path/path.dart' as p;

class CubitTemplate {
  /// featurePath: full path to 'lib/features/module/presentation/cubit'
  static Future<void> create(String featurePath, String stateName) async {
    Directory(featurePath).createSync(recursive: true);

    final className = _pascal(stateName);
    final snakeName = _snakeCase(stateName);

    final files = {
      '${snakeName}_cubit.dart': _cubitFile(className, snakeName),
      '${snakeName}_state.dart': _stateFile(className, snakeName),
    };

    files.forEach((name, content) {
      final filePath = p.join(featurePath, name);
      File(filePath).writeAsStringSync(content);
    });
  }

  static String _cubitFile(String className, String snakeName) => '''
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part '${snakeName}_state.dart';

class ${className}Cubit extends Cubit<${className}State> {
  ${className}Cubit() : super(const ${className}Initial());

  void start() {
    // TODO: implement logic
  }
}
''';

  static String _stateFile(String className, String snakeName) => '''
part of '${snakeName}_cubit.dart';

sealed class ${className}State extends Equatable {
  const ${className}State();

  @override
  List<Object?> get props => [];
}

class ${className}Initial extends ${className}State {
  const ${className}Initial();
  @override
  List<Object?> get props => [];
}

class ${className}Loading extends ${className}State {
  const ${className}Loading();
  @override
  List<Object?> get props => [];
}

class ${className}Success extends ${className}State {
  const ${className}Success();
  @override
  List<Object?> get props => [];
}

class ${className}Failure extends ${className}State {
  const ${className}Failure();
  @override
  List<Object?> get props => [];
}
''';

  static String _snakeCase(String text) => text
      .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]}_${m[2]}')
      .toLowerCase();

  static String _pascal(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}
