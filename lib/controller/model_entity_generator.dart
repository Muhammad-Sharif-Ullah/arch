import 'dart:convert';
import 'dart:io';

import 'package:arch_cli/utils/command.dart';
import 'package:arch_cli/utils/dart_fix.dart';
import 'package:change_case/change_case.dart';
import 'package:interact/interact.dart' show Input, ValidationError;
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// CLI Generator: Converts JSON → Entity + Model files + Extensions
/// Supports nested objects, lists, and json_serializable mappings
class EntityModelController {
  Future<void> call({required String moduleName}) async {
    // ────────────────────────────────
    // 3️⃣ Validate project directory
    // ────────────────────────────────
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      print('\n❌ pubspec.yaml not found in your project directory.');
      print(
          '👉 Please run this command inside a valid Flutter/Dart project.\n');
      return;
    }

    final yamlString = await pubspecFile.readAsString();
    final doc = loadYaml(yamlString);
    final projectName = doc['name']?.toString() ?? 'unknown_project';

    final featuresPath = p.join('lib', 'features', moduleName);
    if (!Directory(featuresPath).existsSync()) {
      print('⚠️  Module "$moduleName" not found under lib/features/');
      return;
    }

    final baseName = Input(
      prompt: 'Enter the base name for Entity/Model (snake_case): ',
      validator: _snakeValidator,
    ).interact();

    final jsonFilePath = Input(
      prompt: 'Enter JSON file path: ',
      validator: _pathValidator,
    ).interact();

    final file = File(jsonFilePath);
    if (!await file.exists()) {
      print('❌ File not found: $jsonFilePath');
      exit(1);
    }

    final jsonData = jsonDecode(await file.readAsString());
    Map<String, dynamic> rootObject;
    if (jsonData is Map<String, dynamic> &&
        jsonData.containsKey(baseName) &&
        jsonData[baseName] is Map<String, dynamic>) {
      rootObject = Map<String, dynamic>.from(jsonData[baseName]);
      for (final key in jsonData.keys) {
        if (key != baseName) rootObject[key] = jsonData[key];
      }
    } else if (jsonData is Map<String, dynamic>) {
      rootObject = Map<String, dynamic>.from(jsonData);
    } else {
      print('❌ Expected a JSON object at root');
      exit(1);
    }

    final rootClass = _toPascal(baseName);
    final Map<String, Map<String, FieldInfo>> classes = {};
    _analyzeMap(rootObject, rootClass, classes);

    // ---------- GENERATE ENTITY FILES ----------
    final entityDir = Directory('lib/features/$moduleName/domain/entities');
    await entityDir.create(recursive: true);

    for (final entry in classes.entries) {
      final content = _renderEntityFile(entry.key, '${entry.key}Entity',
          entry.value, classes, moduleName, projectName);
      await File('${entityDir.path}/${_toSnake(entry.key)}_entity.dart')
          .writeAsString(content);
    }

    // ---------- GENERATE MODEL FILES ----------
    final modelDir = Directory('lib/features/$moduleName/data/model');
    await modelDir.create(recursive: true);

    for (final entry in classes.entries) {
      final content = _renderModelFile(entry.key, '${entry.key}Model',
          entry.value, classes, moduleName, projectName);
      await File('${modelDir.path}/${_toSnake(entry.key)}_model.dart')
          .writeAsString(content);
    }

    // ---------- GENERATE EXTENSIONS ----------
    final extFile = File('lib/core/extensions/${moduleName}_ext.dart');
    await extFile.create(recursive: true);
    await extFile
        .writeAsString(_renderExtensions(classes, moduleName, projectName));

    print('✅ Generated Entities, Models, and Extensions successfully');

    await runCommand('dart', ['format', '.']);
    await DartFix.fixer();
    await runCommand('dart', [
      'run',
      'build_runner',
      'build',
    ]);
  }

  // ---------------- ANALYZE JSON ----------------
  void _analyzeMap(Map<String, dynamic> map, String className,
      Map<String, Map<String, FieldInfo>> classes) {
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

      if (value is int) {
        info.addType(FieldType.intType);
      } else if (value is double) {
        info.addType(FieldType.doubleType);
      } else if (value is bool) {
        info.addType(FieldType.boolType);
      } else if (value is String) {
        info.addType(FieldType.stringType);
      } else if (value is Map<String, dynamic>) {
        info.addType(FieldType.objectType);
        final nested = _deriveNestedClassName(className, key, false);
        info.refClass = nested;
        _analyzeMap(value, nested, classes);
      } else if (value is List) {
        info.addType(FieldType.listType);
        if (value.isEmpty) {
          info.listItemTypes.add(FieldType.dynamicType);
        } else {
          for (final item in value) {
            if (item is Map<String, dynamic>) {
              info.listItemTypes.add(FieldType.objectType);
              final nested = _deriveNestedClassName(className, key, true);
              info.refClass = nested;
              _analyzeMap(item, nested, classes);
            } else if (item is int) {
              info.listItemTypes.add(FieldType.intType);
            } else if (item is double) {
              info.listItemTypes.add(FieldType.doubleType);
            } else if (item is bool) {
              info.listItemTypes.add(FieldType.boolType);
            } else if (item is String) {
              info.listItemTypes.add(FieldType.stringType);
            }
          }
        }
      }
    }
  }

  // ---------------- ENTITY RENDER ----------------
  String _renderEntityFile(
    String baseClassName,
    String className,
    Map<String, FieldInfo> fields,
    Map<String, Map<String, FieldInfo>> classes,
    String moduleName,
    String projectName,
  ) {
    final sb = StringBuffer();

    sb.writeln("import 'package:equatable/equatable.dart';");
    sb.writeln("import 'package:json_annotation/json_annotation.dart';");
    sb.writeln(
        "import 'package:$projectName/features/$moduleName/data/model/${_toSnake(baseClassName)}_model.dart';");

    for (final f in fields.values) {
      if (f.refClass != null) {
        sb.writeln(
            "import 'package:$projectName/features/$moduleName/domain/entities/${_toSnake(f.refClass!)}_entity.dart';");
      }
    }

    sb.writeln('\n/// Domain layer entity for $baseClassName');
    sb.writeln(
        '/// Represents the pure business object, free of serialization logic.');
    sb.writeln('class $className extends Equatable {');

    // Fields
    for (final e in fields.entries) {
      final originalName = e.key;
      final info = e.value;
      final name = _toValidVariable(originalName);

      if (info.refClass != null) {
        final prefix = '${baseClassName}Model';
        final func = _toCamel(info.refClass!);

        if (info.isList) {
          sb.writeln(
              '  @JsonKey(fromJson: $prefix.listOf${_toPascal(info.refClass!)}FromJson, toJson: $prefix.listOf${_toPascal(info.refClass!)}ToJson, name: \'$originalName\', defaultValue: [])');
        } else {
          sb.writeln(
              '  @JsonKey(fromJson: $prefix.${func}FromJson, toJson: $prefix.${func}ToJson, name: \'$originalName\')');
        }
      } else {
        sb.writeln('  @JsonKey(name: \'$originalName\')');
      }

      final dartType = _fieldDartType(info, isEntity: true);
      final nullableType =
          info.nullable && !dartType.endsWith('?') ? '$dartType?' : dartType;
      sb.writeln('  final $nullableType $name;');
    }

    // Constructor
    sb.writeln('\n  const $className({');
    for (final e in fields.entries) {
      final name = _toValidVariable(e.key);
      final info = e.value;

      if (info.nullable) {
        sb.writeln('    this.$name,'); // optional for nullable
      } else {
        sb.writeln('    required this.$name,'); // required for non-nullable
      }
    }
    sb.writeln('  });\n');

    // CopyWith
    sb.writeln('  $className copyWith({');
    for (final e in fields.entries) {
      sb.writeln(
          '    ${_fieldDartType(e.value, isEntity: true)}? ${_toValidVariable(e.key)},');
    }
    sb.writeln('  }) => $className(');
    for (final e in fields.entries) {
      final name = _toValidVariable(e.key);
      sb.writeln('    $name: $name ?? this.$name,');
    }
    sb.writeln('  );\n');

    sb.writeln('  @override');
    sb.writeln(
        '  List<Object?> get props => [${fields.keys.map(_toValidVariable).join(', ')}];');

    sb.writeln('}');
    return sb.toString();
  }

  // ---------------- MODEL RENDER ----------------
  String _renderModelFile(
    String baseClassName,
    String className,
    Map<String, FieldInfo> fields,
    Map<String, Map<String, FieldInfo>> classes,
    String moduleName,
    String projectName,
  ) {
    final sb = StringBuffer();
    sb.writeln("import 'package:json_annotation/json_annotation.dart';");
    sb.writeln(
        "import 'package:$projectName/features/$moduleName/domain/entities/${_toSnake(baseClassName)}_entity.dart';");
    sb.writeln(
        "import 'package:$projectName/core/extensions/${moduleName}_ext.dart';");

    for (final f in fields.values) {
      if (f.refClass != null) {
        sb.writeln("import '${_toSnake(f.refClass!)}_model.dart';");
        sb.writeln(
            "import 'package:$projectName/features/$moduleName/domain/entities/${_toSnake(f.refClass!)}_entity.dart';");
      }
    }

    sb.writeln("\npart '${_toSnake(baseClassName)}_model.g.dart';\n");
    sb.writeln('@JsonSerializable(explicitToJson: true)');
    sb.writeln('class $className extends ${baseClassName}Entity {');

    // Constructor
    sb.writeln('  const $className({');
    for (final e in fields.entries) {
      final name = _toValidVariable(e.key);
      final info = e.value;

      if (info.nullable) {
        sb.writeln('    super.$name,'); // optional for nullable
      } else {
        sb.writeln('    required super.$name,'); // required for non-nullable
      }
    }
    sb.writeln('  });');

    // JSON Methods
    sb.writeln(
        '  factory $className.fromJson(Map<String, dynamic> json) => _\$${className}FromJson(json);');
    sb.writeln(
        '  Map<String, dynamic> toJson() => _\$${className}ToJson(this);\n');

    // Helper Methods for nested objects
    for (final e in fields.entries) {
      final info = e.value;
      if (info.refClass == null) continue;
      final ref = info.refClass!;
      final camel = ref.toCamelCase();

      if (info.nullable) {
        sb.writeln(
            '  static ${ref}Model? ${camel}FromJson(Map<String, dynamic>? json) => json == null ? null : ${ref}Model.fromJson(json);');
        sb.writeln(
            '  static Map<String, dynamic>? ${camel}ToJson(${ref}Entity? obj) => obj == null ? null : (obj as ${ref}Model).toJson();');
      } else {
        sb.writeln(
            '  static ${ref}Model ${camel}FromJson(Map<String, dynamic> json) => ${ref}Model.fromJson(json);');
        sb.writeln(
            '  static Map<String, dynamic> ${camel}ToJson(${ref}Entity obj) => (obj as ${ref}Model).toJson();');
      }

      if (info.isList) {
        sb.writeln(
            '  static List<${ref}Model> listOf${ref}FromJson(List<dynamic> list) => list.map((e) => ${ref}Model.fromJson(e as Map<String, dynamic>)).toList();');
        sb.writeln(
            '  static List<Map<String, dynamic>> listOf${ref}ToJson(List<${ref}Entity> list) => list.map((e) => (e as ${ref}Model).toJson()).toList();');
      }
    }

    sb.writeln('}');
    return sb.toString();
  }

  // ---------------- EXTENSIONS ----------------
  String _renderExtensions(Map<String, Map<String, FieldInfo>> classes,
      String moduleName, String projectName) {
    final sb = StringBuffer();
    final imports = <String>{};

    for (final entry in classes.entries) {
      final base = entry.key;
      imports.add(
          "import 'package:$projectName/features/$moduleName/data/model/${_toSnake(base)}_model.dart';");
      imports.add(
          "import 'package:$projectName/features/$moduleName/domain/entities/${_toSnake(base)}_entity.dart';");
    }

    sb.writeln('// ==========================================================');
    sb.writeln(
        '// Auto-generated model <-> entity extensions for module: $moduleName');
    sb.writeln('// ==========================================================');
    sb.writeln();

    for (final imp in imports) {
      sb.writeln(imp);
    }
    sb.writeln();

    for (final entry in classes.entries) {
      final base = entry.key;
      final fields = entry.value;

      final modelClass = '${base}Model';
      final entityClass = '${base}Entity';

      sb.writeln(
          '// ----------------------------------------------------------');
      sb.writeln('// Converters for $base');
      sb.writeln(
          '// ----------------------------------------------------------\n');

      sb.writeln('extension ${base}ModelExt on $modelClass {');
      sb.writeln('  $entityClass toEntity() => $entityClass(');
      for (final f in fields.entries) {
        final name = _toValidVariable(f.key);
        final info = f.value;

        if (info.isObjectRef && info.refClass != null) {
          if (info.nullable) {
            sb.writeln('    $name: $name?.toModel(),');
          } else {
            sb.writeln('    $name: $name.toModel(),');
          }
        } else if (info.isList && info.refClass != null) {
          sb.writeln('    $name: $name.map((e) => e.toModel()).toList(),');
        } else {
          sb.writeln('    $name: $name,');
        }
      }
      sb.writeln('  );\n}\n');

      sb.writeln('extension ${base}EntityExt on $entityClass {');
      sb.writeln('  $modelClass toModel() => $modelClass(');
      for (final f in fields.entries) {
        final name = _toValidVariable(f.key);
        final info = f.value;

        if (info.isObjectRef && info.refClass != null) {
          if (info.nullable) {
            sb.writeln('    $name: $name?.toModel(),');
          } else {
            sb.writeln('    $name: $name.toModel(),');
          }
        } else if (info.isList && info.refClass != null) {
          sb.writeln('    $name: $name.map((e) => e.toModel()).toList(),');
        } else {
          sb.writeln('    $name: $name,');
        }
      }
      sb.writeln('  );\n}\n');
    }

    sb.writeln('// End of auto-generated extensions');
    return sb.toString();
  }

  // ---------------- UTILITIES ----------------
  String _fieldDartType(FieldInfo info, {bool isEntity = false}) {
    if (info.isList) {
      if (info.listItemTypes.contains(FieldType.objectType) &&
          info.refClass != null) {
        return 'List<${info.refClass! + (isEntity ? "Entity" : "Model")}>';
      }
      return 'List<${_coalescePrimitive(info.listItemTypes.toSet())}>';
    }
    if (info.isObjectRef && info.refClass != null) {
      return info.refClass! + (isEntity ? 'Entity' : 'Model');
    }
    return _coalescePrimitive(info.types.toSet());
  }

  String _coalescePrimitive(Set<FieldType> types) {
    if (types.contains(FieldType.stringType)) return 'String';
    if (types.contains(FieldType.intType)) return 'int';
    if (types.contains(FieldType.doubleType)) return 'double';
    if (types.contains(FieldType.boolType)) return 'bool';
    return 'dynamic';
  }

  String _deriveNestedClassName(String parent, String field, bool isListItem) =>
      isListItem ? '${_toPascal(field)}Item' : _toPascal(field);

  String _toSnake(String name) => name
      .replaceAllMapped(RegExp('([a-z0-9])([A-Z])'), (m) => '${m[1]}_${m[2]}')
      .toLowerCase();
  String _toPascal(String name) =>
      name.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join();
  String _toCamel(String name) {
    if (name.contains('_')) {
      // snake_case → camelCase
      final parts = name.split('_');
      return parts.first.toLowerCase() +
          parts.skip(1).map((w) => w[0].toUpperCase() + w.substring(1)).join();
    } else {
      // PascalCase or single word → camelCase
      return name[0].toLowerCase() + name.substring(1);
    }
  }

  String _toValidVariable(String name) {
    String n = name.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    if (RegExp(r'^[0-9]').hasMatch(n)) n = 'v$n';
    if (n.startsWith('_')) n = 'v${n.replaceAll(RegExp(r'^_+'), '')}';

    // Handle special case for custom_webhooks → customWebHooks
    return _toCamel(n);
  }

  bool _snakeValidator(String x) {
    if (x.isEmpty) throw ValidationError('Name cannot be empty');
    if (x.contains(' ')) throw ValidationError('No spaces allowed');
    if (x.contains(RegExp(r'[A-Z]'))) {
      throw ValidationError('Must be snake_case');
    }
    return true;
  }

  bool _pathValidator(String x) {
    if (x.isEmpty) throw ValidationError('File path cannot be empty');
    return true;
  }
}

// ---------------- FIELD INFO ----------------
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
