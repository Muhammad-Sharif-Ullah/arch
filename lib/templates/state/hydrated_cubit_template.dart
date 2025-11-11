import 'dart:io';
import 'package:path/path.dart' as p;

class HydratedCubitTemplate {
  static Future<void> create(String targetPath, String stateName) async {
    final className = _pascal(stateName);
    Directory(targetPath).createSync(recursive: true);

    final files = {
      '${stateName}_hydrated_cubit.dart': _cubitFile(className, stateName),
      '${stateName}_state.dart': _stateFile(className, stateName),
    };

    files.forEach((name, content) {
      final filePath = p.join(targetPath, name);
      File(filePath).writeAsStringSync(content);
    });
  }

  static String _cubitFile(String className, String stateName) => '''
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
part '${stateName}_state.dart';

class ${className}HydratedCubit extends HydratedCubit<${className}State> {
  ${className}HydratedCubit() : super(const ${className}State());

  void increment() => emit(${className}State(counter: state.counter + 1));

  @override
  ${className}State? fromJson(Map<String, dynamic> json) =>
      ${className}State.fromMap(json);

  @override
  Map<String, dynamic>? toJson(${className}State state) => state.toMap();
}
''';

  static String _stateFile(String className, String stateName) => '''
part of '${stateName}_cubit.dart';

class ${className}State  extends Equatable{
  final int counter;
  const ${className}State({this.counter = 0});

  Map<String, dynamic> toMap() => {'counter': counter};

  factory ${className}State.fromMap(Map<String, dynamic> map) {
      ${className}State(counter: map['counter'] ?? 0);
  }

  @override
  List<Object?> get props => [counter];
}
''';

  static String _pascal(String input) =>
      input.split('_').map((e) => e[0].toUpperCase() + e.substring(1)).join();
}
