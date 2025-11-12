import 'dart:convert';
import 'dart:io';
import 'package:arch/utils/command.dart';
import 'package:arch/utils/dart_fix.dart';
import 'package:interact/interact.dart' show Input, ValidationError;

/// CLI JSON-to-Model generator for Dart (json_serializable)
/// Generates models in: lib/feature/<module>/data/model/<modelName>/
class ModelController {
  Future<void> call({required String moduleName}) async {
    final modelName = Input(
      prompt: 'Enter the Model name (snake_case): ',
      defaultValue: 'auth',
      validator: _snakeValidator,
    ).interact();

    final jsonFilePath = Input(
      prompt: 'Enter json file path: ',
      validator: _pathValidator,
    ).interact();

    final file = File(jsonFilePath);
    if (!await file.exists()) {
      print('❌ File not found: $jsonFilePath');
      exit(1);
    }

    final jsonData = jsonDecode(await file.readAsString());
    if (jsonData is! Map<String, dynamic>) {
      print('❌ Expected a JSON object (Map), not a list');
      exit(1);
    }

    final outputDir =
        Directory('lib/feature/$moduleName/data/model/$modelName');
    await outputDir.create(recursive: true);

    // Determine root object
    final rootKeyNames = jsonData.keys.toList();
    Map<String, dynamic> rootObject;
    final rootClassBase = _toPascal(modelName);

    if (rootKeyNames.length == 1 &&
        rootKeyNames[0] == modelName &&
        jsonData[modelName] is Map<String, dynamic>) {
      rootObject = Map<String, dynamic>.from(jsonData[modelName] as Map);
    } else {
      rootObject = Map<String, dynamic>.from(jsonData);
    }

    final Map<String, Map<String, FieldInfo>> classes = {};
    _analyzeMap(rootObject, rootClassBase, classes);

    // Generate model files
    for (final entry in classes.entries) {
      final className = '${entry.key}Model';
      final fields = entry.value;
      final fileContent =
          _renderClassFile(entry.key, className, fields, classes);
      final outFile =
          File('${outputDir.path}/${_toSnake(entry.key)}_model.dart');
      await outFile.writeAsString(fileContent);
    }

    print('✅ Models generated under: ${outputDir.path}');
    print('💡 Run: dart run build_runner build --delete-conflicting-outputs');

    await runCommand('dart',
        ['run', 'build_runner', 'build', '--delete-conflicting-outputs']);

    DartFix.fixer();
  }

  // ---------- ANALYSIS ----------

  void _analyzeMap(
    Map<String, dynamic> map,
    String className,
    Map<String, Map<String, FieldInfo>> classes,
  ) {
    final fields = classes.putIfAbsent(className, () => {});

    for (final entry in map.entries) {
      final key = entry.key;
      final value = entry.value;
      final info = fields.putIfAbsent(key, () => FieldInfo());
      info.seen = true;

      if (value == null) {
        info.nullable = true;
        info.addType(FieldType.dynamicType);
        continue;
      }

      if (value is int)
        info.addType(FieldType.intType);
      else if (value is double)
        info.addType(FieldType.doubleType);
      else if (value is bool)
        info.addType(FieldType.boolType);
      else if (value is String)
        info.addType(FieldType.stringType);
      else if (value is Map<String, dynamic>) {
        info.addType(FieldType.objectType);
        final nestedName = _deriveNestedClassName(className, key, false);
        info.refClass = nestedName;
        _analyzeMap(value, nestedName, classes);
      } else if (value is List) {
        info.addType(FieldType.listType);
        if (value.isEmpty) {
          info.listItemTypes.add(FieldType.dynamicType);
        } else {
          for (final item in value) {
            if (item == null) {
              info.listItemNullable = true;
              continue;
            }
            if (item is int) {
              info.listItemTypes.add(FieldType.intType);
            } else if (item is double) {
              info.listItemTypes.add(FieldType.doubleType);
            } else if (item is bool) {
              info.listItemTypes.add(FieldType.boolType);
            } else if (item is String) {
              info.listItemTypes.add(FieldType.stringType);
            } else if (item is Map<String, dynamic>) {
              info.listItemTypes.add(FieldType.objectType);
              final nestedName = _deriveNestedClassName(className, key, true);
              info.refClass = nestedName;
              _analyzeMap(item, nestedName, classes);
            }
          }
        }
      } else {
        info.addType(FieldType.dynamicType);
      }
    }
  }

  String _deriveNestedClassName(String parent, String field, bool isListItem) {
    final base = _toPascal(field);
    return isListItem ? '${base}Item' : base;
  }

  // ---------- RENDERING ----------

  String _renderClassFile(
    String baseClassName,
    String className,
    Map<String, FieldInfo> fields,
    Map<String, Map<String, FieldInfo>> classes,
  ) {
    final sb = StringBuffer();
    sb.writeln("import 'package:json_annotation/json_annotation.dart';");

    final imports = <String>{};
    for (final f in fields.values) {
      if (f.refClass != null) imports.add(f.refClass!);
    }
    for (final ref in imports) {
      if (ref == baseClassName) continue;
      sb.writeln("import '${_toSnake(ref)}_model.dart';");
    }

    sb.writeln();
    sb.writeln("part '${_toSnake(baseClassName)}_model.g.dart';\n");
    sb.writeln('@JsonSerializable(explicitToJson: true)');
    sb.writeln('class $className {');

    for (final entry in fields.entries) {
      final name = entry.key;
      final info = entry.value;
      sb.writeln('  final ${_fieldDartType(info)} $name;');
    }

    sb.writeln('\n  const $className({');
    for (final entry in fields.entries) {
      final name = entry.key;
      final info = entry.value;
      if (_isFieldNullable(info)) {
        sb.writeln('    this.$name,');
      } else {
        sb.writeln('    required this.$name,');
      }
    }
    sb.writeln('  });\n');

    sb.writeln(
        '  factory $className.fromJson(Map<String, dynamic> json) => _\$${className}FromJson(json);');
    sb.writeln(
        '  Map<String, dynamic> toJson() => _\$${className}ToJson(this);');
    sb.writeln('}');
    return sb.toString();
  }

  String _fieldDartType(FieldInfo info) {
    if (info.isList) {
      if (info.listItemTypes.contains(FieldType.objectType) &&
          info.refClass != null) {
        final itemType = '${info.refClass!}Model';
        final nullable = _isFieldNullable(info) ? '?' : '';
        return 'List<$itemType>$nullable';
      } else {
        final itemType = _coalescePrimitive(info.listItemTypes.toSet());
        final nullable = _isFieldNullable(info) ? '?' : '';
        return 'List<$itemType>$nullable';
      }
    } else if (info.isObjectRef && info.refClass != null) {
      final nullable = _isFieldNullable(info) ? '?' : '';
      return '${info.refClass!}Model$nullable';
    } else {
      final primitive = _coalescePrimitive(info.types.toSet());
      final nullable = _isFieldNullable(info) ? '?' : '';
      return '$primitive$nullable';
    }
  }

  bool _isFieldNullable(FieldInfo info) => info.nullable;

  String _coalescePrimitive(Set<FieldType> t) {
    if (t.contains(FieldType.stringType)) return 'String';
    if (t.contains(FieldType.intType)) return 'int';
    if (t.contains(FieldType.doubleType)) return 'double';
    if (t.contains(FieldType.boolType)) return 'bool';
    return 'dynamic';
  }

  // ---------- Utils ----------

  String _toSnake(String name) => name
      .replaceAllMapped(RegExp('([a-z0-9])([A-Z])'), (m) => '${m[1]}_${m[2]}')
      .toLowerCase();

  String _toPascal(String name) => name
      .split('_')
      .where((s) => s.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join();

  bool _snakeValidator(String x) {
    if (x.isEmpty) throw ValidationError('Name cannot be empty');
    if (x.contains(' ')) throw ValidationError('No spaces allowed');
    if (x.contains(RegExp(r'[A-Z]')))
      throw ValidationError('Must be snake_case');
    return true;
  }

  bool _pathValidator(String x) {
    if (x.isEmpty) throw ValidationError('File path cannot be empty');
    return true;
  }
}

// ---------- FIELD INFO ----------

enum FieldType {
  intType,
  doubleType,
  boolType,
  stringType,
  objectType,
  listType,
  dynamicType
}

class FieldInfo {
  final List<FieldType> types = [];
  bool nullable = false;
  bool seen = false;
  String? refClass;
  final List<FieldType> listItemTypes = [];
  bool listItemNullable = false;

  void addType(FieldType t) => types.add(t);
  bool get isList => types.contains(FieldType.listType);
  bool get isObjectRef => types.contains(FieldType.objectType);
}
