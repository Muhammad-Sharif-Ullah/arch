import 'dart:io';
import 'package:path/path.dart' as p;

class BlocTemplate {
  /// featurePath should be the full path to the folder (lib/feature/module/presentation/bloc)
  static Future<void> create(String featurePath, String stateName) async {
    // Ensure directory exists
    Directory(featurePath).createSync(recursive: true);

    final className = _pascal(stateName);
    final snakeName = _snakeCase(stateName);

    final files = {
      '${snakeName}_bloc.dart': _blocFile(className, snakeName),
      '${snakeName}_event.dart': _eventFile(className, snakeName),
      '${snakeName}_state.dart': _stateFile(className, snakeName),
    };

    files.forEach((name, content) {
      final filePath = p.join(featurePath, name);
      File(filePath).writeAsStringSync(content);
    });
  }

  static String _blocFile(String className, String snakeName) => '''
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part '${snakeName}_event.dart';
part '${snakeName}_state.dart';

class ${className}Bloc extends Bloc<${className}Event, ${className}State> {
  ${className}Bloc() : super(${className}Initial()) {
    on<${className}Started>(_onStarted);
  }

  void _onStarted(${className}Started event, Emitter<${className}State> emit) {
    // TODO: implement event handler
  }
}
''';

  static String _eventFile(String className, String snakeName) => '''
part of '${snakeName}_bloc.dart';

sealed class ${className}Event extends Equatable {
  const ${className}Event();

  @override
  List<Object?> get props => [];
}

class ${className}Started extends ${className}Event {}
''';

  static String _stateFile(String className, String snakeName) => '''
part of '${snakeName}_bloc.dart';

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
