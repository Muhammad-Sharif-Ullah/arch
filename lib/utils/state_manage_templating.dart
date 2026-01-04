import 'dart:io';

import 'package:change_case/change_case.dart';

class StateManageTemplating {
  StateManageTemplating._();

  // ────────────────────────────────
  // PUBLIC API
  // ────────────────────────────────

  static Future<void> addBlocToLocator(
    String moduleName,
    String projectName,
  ) async {
    await _addBloc(moduleName, projectName);
  }

  static Future<void> addCubitToLocator(
    String moduleName,
    String projectName,
  ) async {
    await _addCubit(moduleName, projectName);
  }

  static Future<void> addHydratedBlocToLocator(
    String moduleName,
    String projectName,
  ) async {
    await _addHydratedBlocToLocator(moduleName, projectName);
  }

  static Future<void> addHydratedCubitToLocator(
    String moduleName,
    String projectName,
  ) async {
    await _addHydratedCubitToLocator(moduleName, projectName);
  }

  // ────────────────────────────────
  // BLOC GENERATOR
  // ────────────────────────────────

  static Future<void> _addBloc(
    String moduleName,
    String projectName,
  ) async {
    final featureName = moduleName.toSnakeCase();
    final className = moduleName.toCapitalCase();

    final blocDir = Directory('lib/features/$featureName/presentation/bloc');

    // ✅ ENSURE DIRECTORY EXISTS
    if (!blocDir.existsSync()) {
      blocDir.createSync(recursive: true);
    }

    final blocFile = File('${blocDir.path}/${featureName}_bloc.dart');
    final eventFile = File('${blocDir.path}/${featureName}_event.dart');
    final stateFile = File('${blocDir.path}/${featureName}_state.dart');

    // ────────────────────────────────
    // BLOC CODE
    // ────────────────────────────────

    final blocCode = '''
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:$projectName/features/$featureName/domain/usecases/${featureName}_uc.dart';
import 'package:$projectName/features/$featureName/data/models/${featureName}_payload.dart';
import 'package:$projectName/features/$featureName/domain/entities/${featureName}_entity.dart';
import 'package:$projectName/core/clients/network/api_response.dart';


part '${featureName}_event.dart';
part '${featureName}_state.dart';

class ${className}Bloc
    extends Bloc<${className}Event, ${className}State> {

  final ${className}UseCase useCase;

  ${className}Bloc(this.useCase)
      : super(const ${className}Initial()) {

    on<Fetch${className}Event>(_onFetch);
  }

  Future<void> _onFetch(
    Fetch${className}Event event,
    Emitter<${className}State> emit,
  ) async {
    emit(const ${className}Loading());

    final result = await useCase.call(event.payload);

    result.fold(
      (failure) => emit(
        ${className}Error(failure: failure),
      ),
      (data) => emit(
        ${className}Loaded(data: data),
      ),
    );
  }
}
''';

    // ────────────────────────────────
    // EVENT CODE
    // ────────────────────────────────

    final eventCode = '''
part of '${featureName}_bloc.dart';

abstract class ${className}Event extends Equatable {
  const ${className}Event();

  @override
  List<Object?> get props => [];
}

class Fetch${className}Event extends ${className}Event {
  final ${className}Payload payload;

  const Fetch${className}Event({required this.payload});

  @override
  List<Object?> get props => [payload];
}
''';

    // ────────────────────────────────
    // STATE CODE
    // ────────────────────────────────

    final stateCode = '''
part of '${featureName}_bloc.dart';

abstract class ${className}State extends Equatable {
  const ${className}State();

  @override
  List<Object?> get props => [];
}

class ${className}Initial extends ${className}State {
  const ${className}Initial();
}

class ${className}Loading extends ${className}State {
  const ${className}Loading();
}

class ${className}Loaded extends ${className}State {
  final ${className}Entity data;

  const ${className}Loaded({required this.data});

  @override
  List<Object?> get props => [data];
}

class ${className}Error extends ${className}State {
  final ResponseFailure<AuthEntity> failure;

  const ${className}Error({required this.failure});

  @override
  List<Object?> get props => [failure];
  String get message => failure.error;
}
''';

    // ────────────────────────────────
    // WRITE FILES
    // ────────────────────────────────

    try {
      await blocFile.writeAsString(blocCode);
      await eventFile.writeAsString(eventCode);
      await stateFile.writeAsString(stateCode);

      // updadte locator
      final locatorFile =
          File('lib/features/$featureName/di/${featureName}_di.dart');
      String locatorContent = await locatorFile.readAsString();
      // check if already have import
      locatorContent = locatorContent = _ensureImport(
        locatorContent,
        "import 'package:$projectName/features/$featureName/presentation/bloc/${featureName}_bloc.dart';",
      );
      // remove previous registration if any
      locatorContent = locatorContent.replaceAll(
        RegExp(r'\s+instance\.registerFactory<' +
            className +
            r'Bloc>\(\)\s*=\> [^\;]*;\n?'),
        '',
      );
      // add new registration
      final setupRegex = RegExp(
        r'static void register\(GetIt instance, \{required AppEnvironment environment\}\) \{([\s\S]*?)\n\s*\}',
      );
      locatorContent = locatorContent.replaceFirstMapped(
        setupRegex,
        (match) {
          final existingContent = match.group(1);
          final updatedContent =
              '$existingContent\n\n    instance.registerFactory<${className}Bloc>(() => ${className}Bloc(instance()));';
          return 'static void register(GetIt instance, {required AppEnvironment environment}) {$updatedContent\n  }';
        },
      );

      await locatorFile.writeAsString(locatorContent);

      print('✅ Bloc created for "$moduleName"');
    } catch (e) {
      print('❌ Failed to create Bloc for "$moduleName": $e');
    }
  }

  // ────────────────────────────────
// CUBIT GENERATOR
// ────────────────────────────────

  static Future<void> _addCubit(
    String moduleName,
    String projectName,
  ) async {
    final featureName = moduleName.toSnakeCase();
    final className = moduleName.toCapitalCase();

    final cubitDir = Directory('lib/features/$featureName/presentation/cubit');

    // ✅ Ensure directory exists
    if (!cubitDir.existsSync()) {
      cubitDir.createSync(recursive: true);
    }

    final cubitFile = File('${cubitDir.path}/${featureName}_cubit.dart');
    final stateFile = File('${cubitDir.path}/${featureName}_state.dart');

    // ────────────────────────────────
    // CUBIT CODE
    // ────────────────────────────────

    final cubitCode = '''
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:$projectName/features/$featureName/domain/usecases/${featureName}_uc.dart';
import 'package:$projectName/features/$featureName/data/models/${featureName}_payload.dart';
import 'package:$projectName/features/$featureName/domain/entities/${featureName}_entity.dart';
import 'package:$projectName/core/clients/network/api_response.dart';

part '${featureName}_state.dart';

class ${className}Cubit extends Cubit<${className}State> {
  final ${className}UseCase useCase;

  ${className}Cubit(this.useCase)
      : super(const ${className}Initial());

  Future<void> fetch(${className}Payload payload) async {
    emit(const ${className}Loading());

    final result = await useCase.call(payload);

    result.fold(
      (failure) => emit(
        ${className}Error(failure: failure),
      ),
      (data) => emit(
        ${className}Loaded(data: data),
      ),
    );
  }
}
''';

    // ────────────────────────────────
    // STATE CODE
    // ────────────────────────────────

    final stateCode = '''
part of '${featureName}_cubit.dart';

abstract class ${className}State {
  const ${className}State();
}

class ${className}Initial extends ${className}State {
  const ${className}Initial();
}

class ${className}Loading extends ${className}State {
  const ${className}Loading();
}

class ${className}Loaded extends ${className}State {
  final ${className}Entity data;

  const ${className}Loaded({required this.data});
}

class ${className}Error extends ${className}State {
  final ResponseFailure<${className}Entity> failure;

  const ${className}Error({required this.failure});

  String get message => failure.error;
}
''';

    try {
      await cubitFile.writeAsString(cubitCode);
      await stateFile.writeAsString(stateCode);

      // ────────────────────────────────
      // UPDATE LOCATOR
      // ────────────────────────────────

      final locatorFile =
          File('lib/features/$featureName/di/${featureName}_di.dart');

      String locatorContent = await locatorFile.readAsString();

      // ensure import
      locatorContent = _ensureImport(
        locatorContent,
        "import 'package:$projectName/features/$featureName/presentation/cubit/${featureName}_cubit.dart';",
      );

      // remove previous registration if exists
      locatorContent = locatorContent.replaceAll(
        RegExp(r'\s+instance\.registerFactory<' +
            className +
            r'Cubit>\(\)\s*=\> [^\;]*;\n?'),
        '',
      );

      // add new registration
      final setupRegex = RegExp(
        r'static void register\(GetIt instance, \{required AppEnvironment environment\}\) \{([\s\S]*?)\n\s*\}',
      );

      locatorContent = locatorContent.replaceFirstMapped(
        setupRegex,
        (match) {
          final body = match.group(1);
          return '''
static void register(GetIt instance, {required AppEnvironment environment}) {
$body

    instance.registerFactory<${className}Cubit>(
      () => ${className}Cubit(instance()),
    );
  }
''';
        },
      );

      await locatorFile.writeAsString(locatorContent);

      print('✅ Cubit created for "$moduleName"');
    } catch (e) {
      print('❌ Failed to create Cubit for "$moduleName": $e');
    }
  }

  static Future<void> _addHydratedBlocToLocator(
    String moduleName,
    String projectName,
  ) async {
    final featureName = moduleName.toSnakeCase();
    final className = moduleName.toCapitalCase();

    final blocDir = Directory('lib/features/$featureName/presentation/bloc');

    if (!blocDir.existsSync()) {
      blocDir.createSync(recursive: true);
    }

    final blocFile = File('${blocDir.path}/${featureName}_bloc.dart');
    final eventFile = File('${blocDir.path}/${featureName}_event.dart');
    final stateFile = File('${blocDir.path}/${featureName}_state.dart');

    // ───────────── Bloc ─────────────

    final blocCode = '''
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:$projectName/features/$featureName/domain/usecases/${featureName}_uc.dart';
import 'package:$projectName/features/$featureName/data/models/${featureName}_payload.dart';
import 'package:$projectName/features/$featureName/domain/entities/${featureName}_entity.dart';
import 'package:$projectName/core/clients/network/api_response.dart';

part '${featureName}_event.dart';
part '${featureName}_state.dart';

class ${className}Bloc
    extends HydratedBloc<${className}Event, ${className}State> {

  final ${className}UseCase useCase;

  ${className}Bloc(this.useCase)
      : super(${className}Initial()) {
    on<Fetch${className}Event>(_onFetch);
  }

  Future<void> _onFetch(
    Fetch${className}Event event,
    Emitter<${className}State> emit,
  ) async {
    emit(${className}Loading());

    final result = await useCase.call(event.payload);

    result.fold(
      (failure) => emit(${className}Error(failure: failure)),
      (data) => emit(${className}Loaded(data: data)),
    );
  }

  @override
  ${className}State? fromJson(Map<String, dynamic> json) {
    try {
      return ${className}Loaded(
        data: ${className}Entity.fromJson(json),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(${className}State state) {
    if (state is ${className}Loaded) {
      return state.data.toJson();
    }
    return null;
  }
}
''';

    // ───────────── Event ─────────────

    final eventCode = '''
part of '${featureName}_bloc.dart';

abstract class ${className}Event extends Equatable {
  const ${className}Event();

  @override
  List<Object?> get props => [];
}

class Fetch${className}Event extends ${className}Event {
  final ${className}Payload payload;

  const Fetch${className}Event({required this.payload});

  @override
  List<Object?> get props => [payload];
}
''';

    // ───────────── State ─────────────

    final stateCode = '''
part of '${featureName}_bloc.dart';

abstract class ${className}State extends Equatable {
  const ${className}State();

  @override
  List<Object?> get props => [];
}

class ${className}Initial extends ${className}State {}

class ${className}Loading extends ${className}State {}

class ${className}Loaded extends ${className}State {
  final ${className}Entity data;

  const ${className}Loaded({required this.data});

  @override
  List<Object?> get props => [data];
}

class ${className}Error extends ${className}State {
  final ResponseFailure<${className}Entity> failure;

  const ${className}Error({required this.failure});

  @override
  List<Object?> get props => [failure];

  String get message => failure.error;
}
''';

    await blocFile.writeAsString(blocCode);
    await eventFile.writeAsString(eventCode);
    await stateFile.writeAsString(stateCode);

    // ───────────── Update DI ─────────────

    final locatorFile =
        File('lib/features/$featureName/di/${featureName}_di.dart');

    String content = await locatorFile.readAsString();

    content = _ensureImport(
      content,
      "import 'package:$projectName/features/$featureName/presentation/bloc/${featureName}_bloc.dart';",
    );

    final setupRegex = RegExp(
      r'static void register\(GetIt instance, \{required AppEnvironment environment\}\) \{([\s\S]*?)\n\s*\}',
    );

    content = content.replaceFirstMapped(setupRegex, (match) {
      return '''
static void register(GetIt instance, {required AppEnvironment environment}) {
${match.group(1)}

    instance.registerFactory<${className}Bloc>(
      () => ${className}Bloc(instance()),
    );
  }
''';
    });

    await locatorFile.writeAsString(content);

    print('✅ HydratedBloc (no freezed) created for "$moduleName"');
  }

  static Future<void> _addHydratedCubitToLocator(
    String moduleName,
    String projectName,
  ) async {
    final featureName = moduleName.toSnakeCase();
    final className = moduleName.toCapitalCase();

    final cubitDir = Directory('lib/features/$featureName/presentation/cubit');

    if (!cubitDir.existsSync()) {
      cubitDir.createSync(recursive: true);
    }

    final cubitFile = File('${cubitDir.path}/${featureName}_cubit.dart');
    final stateFile = File('${cubitDir.path}/${featureName}_state.dart');

    // ───────────── Cubit ─────────────

    final cubitCode = '''
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:$projectName/features/$featureName/domain/usecases/${featureName}_uc.dart';
import 'package:$projectName/features/$featureName/data/models/${featureName}_payload.dart';
import 'package:$projectName/features/$featureName/domain/entities/${featureName}_entity.dart';
import 'package:$projectName/core/clients/network/api_response.dart';

part '${featureName}_state.dart';

class ${className}Cubit
    extends HydratedCubit<${className}State> {

  final ${className}UseCase useCase;

  ${className}Cubit(this.useCase)
      : super(${className}Initial());

  Future<void> fetch(${className}Payload payload) async {
    emit(${className}Loading());

    final result = await useCase.call(payload);

    result.fold(
      (failure) => emit(${className}Error(failure: failure)),
      (data) => emit(${className}Loaded(data: data)),
    );
  }

  @override
  ${className}State? fromJson(Map<String, dynamic> json) {
    try {
      return ${className}Loaded(
        data: ${className}Entity.fromJson(json),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(${className}State state) {
    if (state is ${className}Loaded) {
      return state.data.toJson();
    }
    return null;
  }
}
''';

    // ───────────── State ─────────────

    final stateCode = '''
part of '${featureName}_cubit.dart';

abstract class ${className}State extends Equatable {
  const ${className}State();

  @override
  List<Object?> get props => [];
}

class ${className}Initial extends ${className}State {}

class ${className}Loading extends ${className}State {}

class ${className}Loaded extends ${className}State {
  final ${className}Entity data;

  const ${className}Loaded({required this.data});

  @override
  List<Object?> get props => [data];
}

class ${className}Error extends ${className}State {
  final ResponseFailure<${className}Entity> failure;

  const ${className}Error({required this.failure});

  @override
  List<Object?> get props => [failure];

  String get message => failure.error;
}
''';

    await cubitFile.writeAsString(cubitCode);
    await stateFile.writeAsString(stateCode);

    // ───────────── Update DI ─────────────

    final locatorFile =
        File('lib/features/$featureName/di/${featureName}_di.dart');

    String content = await locatorFile.readAsString();

    content = _ensureImport(
      content,
      "import 'package:$projectName/features/$featureName/presentation/cubit/${featureName}_cubit.dart';",
    );

    final setupRegex = RegExp(
      r'static void register\(GetIt instance, \{required AppEnvironment environment\}\) \{([\s\S]*?)\n\s*\}',
    );

    content = content.replaceFirstMapped(setupRegex, (match) {
      return '''
static void register(GetIt instance, {required AppEnvironment environment}) {
${match.group(1)}

    instance.registerFactory<${className}Cubit>(
      () => ${className}Cubit(instance()),
    );
  }
''';
    });

    await locatorFile.writeAsString(content);

    print('✅ HydratedCubit (no freezed) created for "$moduleName"');
  }

  // ────────────────────────────────
  // HELPERS
  // ────────────────────────────────
  static String _ensureImport(String content, String importLine) {
    if (content.contains(importLine)) return content;

    final imports = RegExp(r"^import\s+'.*?';", multiLine: true)
        .allMatches(content)
        .toList();

    if (imports.isEmpty) return '$importLine\n$content';

    return content.replaceRange(
      imports.last.end,
      imports.last.end,
      '\n$importLine',
    );
  }
}
