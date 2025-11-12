import 'dart:convert';
import 'dart:io';
import 'package:arch/utils/command.dart';
import 'package:arch/utils/dart_fix.dart';
import 'package:interact/interact.dart' show Input, ValidationError;

/// CLI JSON-to-Entity/Model generator (json_serializable + Equatable)
class EntityModelController {
  Future<void> call({required String moduleName}) async {
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
      print('❌ Expected a JSON object (Map) at root');
      exit(1);
    }

    final rootClass = _toPascal(baseName);
    final Map<String, Map<String, FieldInfo>> classes = {};
    _analyzeMap(rootObject, rootClass, classes);

    // --- ENTITIES ---
    final entityDir = Directory('lib/feature/$moduleName/domain/entities');
    await entityDir.create(recursive: true);

    for (final entry in classes.entries) {
      final className = '${entry.key}Entity';
      final fields = entry.value;
      final content =
          _renderEntityFile(entry.key, className, fields, classes, moduleName);
      final outFile =
          File('${entityDir.path}/${_toSnake(entry.key)}_entity.dart');
      await outFile.writeAsString(content);
    }
    print('✅ Entities generated in: ${entityDir.path}');

    // --- MODELS ---
    final modelDir = Directory('lib/feature/$moduleName/data/model');
    await modelDir.create(recursive: true);

    for (final entry in classes.entries) {
      final className = '${entry.key}Model';
      final fields = entry.value;
      final content =
          _renderModelFile(entry.key, className, fields, classes, moduleName);
      final outFile =
          File('${modelDir.path}/${_toSnake(entry.key)}_model.dart');
      await outFile.writeAsString(content);
    }
    print('✅ Models generated in: ${modelDir.path}');

    // --- EXTENSIONS ---
    final extFile =
        File('lib/core/extensions/${moduleName}_ext.dart'); // <- extension file
    await extFile.create(recursive: true);
    final extContent = _renderExtensions(classes, moduleName);
    await extFile.writeAsString(extContent);
    print('✅ Extensions generated at: ${extFile.path}');

    // Format + Fix + Build
    await runCommand('dart', ['format', '.']);
    await DartFix.fixer();
    await runCommand('dart',
        ['run', 'build_runner', 'build', '--delete-conflicting-outputs']);
  }

  // ---------------- ANALYSIS ----------------
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
              final nested = _deriveNestedClassName(className, key, true);
              info.refClass = nested;
              _analyzeMap(item, nested, classes);
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

  // ---------------- ENTITY RENDER ----------------
  String _renderEntityFile(
      String baseClassName,
      String className,
      Map<String, FieldInfo> fields,
      Map<String, Map<String, FieldInfo>> classes,
      String moduleName) {
    final sb = StringBuffer();
    sb.writeln("import 'package:equatable/equatable.dart';");
    sb.writeln("import 'package:json_annotation/json_annotation.dart';");
    sb.writeln(
        "import 'package:my_project/feature/$moduleName/data/model/${_toSnake(baseClassName)}_model.dart';");

    for (final f in fields.values) {
      if (f.refClass != null) {
        sb.writeln(
            "import 'package:my_project/feature/$moduleName/domain/entities/${_toSnake(f.refClass!)}_entity.dart';");
      }
    }

    sb.writeln('\nclass $className extends Equatable {');

    for (final e in fields.entries) {
      final name = e.key;
      final info = e.value;
      if (info.refClass != null) {
        final helperPrefix = '${baseClassName}Model';
        final func = _toCamel(info.refClass!);
        sb.writeln(
            '  @JsonKey(fromJson: $helperPrefix.${func}FromJson, toJson: $helperPrefix.${func}ToJson)');
      }
      sb.writeln('  final ${_fieldDartType(info, isEntity: true)} $name;');
    }

    sb.writeln('\n  const $className({');
    for (final e in fields.entries) {
      sb.writeln('    required this.${e.key},');
    }
    sb.writeln('  });\n');

    sb.writeln(
        '  @override\n  List<Object?> get props => [${fields.keys.join(', ')}];');
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
  ) {
    final sb = StringBuffer();
    sb.writeln("import 'package:json_annotation/json_annotation.dart';");
    sb.writeln(
        "import 'package:my_project/feature/$moduleName/domain/entities/${_toSnake(baseClassName)}_entity.dart';");
    sb.writeln(
        "import 'package:my_project/core/extensions/${moduleName}_ext.dart';");

    for (final f in fields.values) {
      if (f.refClass != null) {
        sb.writeln("import '${_toSnake(f.refClass!)}_model.dart';");
        sb.writeln(
            "import 'package:my_project/feature/$moduleName/domain/entities/${_toSnake(f.refClass!)}_entity.dart';");
      }
    }

    sb.writeln("\npart '${_toSnake(baseClassName)}_model.g.dart';\n");
    sb.writeln('@JsonSerializable(explicitToJson: true)');
    sb.writeln('class $className extends ${baseClassName}Entity {');

    // Constructor
    sb.writeln('  const $className({');
    for (final e in fields.entries) {
      sb.writeln(
          '    required ${_fieldDartType(e.value, isEntity: false)} super.${e.key},');
    }
    sb.writeln('  });\n');

    // copyWith
    sb.writeln('  $className copyWith({');
    for (final e in fields.entries) {
      sb.writeln('    ${_fieldDartType(e.value, isEntity: false)}? ${e.key},');
    }
    sb.writeln('  }) => $className(');
    for (final e in fields.entries) {
      final info = e.value;
      if (info.isObjectRef || info.isList) {
        sb.writeln(
            '      ${e.key}: ${e.key} ?? (this.${e.key} as ${_fieldDartType(info, isEntity: false)}),');
      } else {
        sb.writeln('      ${e.key}: ${e.key} ?? this.${e.key},');
      }
    }
    sb.writeln('  );\n');

    // JSON
    sb.writeln(
        '  factory $className.fromJson(Map<String, dynamic> json) => _\$${className}FromJson(json);');
    sb.writeln(
        '  Map<String, dynamic> toJson() => _\$${className}ToJson(this);\n');

    // Static helpers (PascalCase names)
    for (final e in fields.entries) {
      final info = e.value;
      if (info.refClass == null) continue;
      final ref = info.refClass!;
      final camel = _toCamel(ref);
      sb.writeln(
          '  static ${ref}Model ${camel}FromJson(Map<String, dynamic> json) => ${ref}Model.fromJson(json);');
      sb.writeln(
          '  static Map<String, dynamic> ${camel}ToJson(${ref}Entity obj) => (obj as ${ref}Model).toJson();');
    }

    sb.writeln('}');
    return sb.toString();
  }

  // ---------------- EXTENSIONS ----------------
  String _renderExtensions(
      Map<String, Map<String, FieldInfo>> classes, String moduleName) {
    final sb = StringBuffer();
    final imports = <String>{};

    for (final entry in classes.entries) {
      final base = entry.key;
      imports.add(
          "import 'package:my_project/feature/$moduleName/data/model/${_toSnake(base)}_model.dart';");
      imports.add(
          "import 'package:my_project/feature/$moduleName/domain/entities/${_toSnake(base)}_entity.dart';");
    }

    sb.writeln('// Auto-generated extensions');
    for (final imp in imports) {
      sb.writeln(imp);
    }
    sb.writeln('');

    for (final entry in classes.entries) {
      final base = entry.key;
      final fields = entry.value;

      // Model → Entity
      sb.writeln('extension ${base}ModelExt on ${base}Model {');
      sb.writeln('  ${base}Entity toEntity() => ${base}Entity(');
      for (final e in fields.entries) {
        final f = e.value;
        if (f.isObjectRef) {
          sb.writeln('    ${e.key}: ${e.key}.toModel(),');
        } else if (f.isList && f.refClass != null) {
          sb.writeln(
              '    ${e.key}: ${e.key}.map((e) => e.toModel()).toList(),');
        } else {
          sb.writeln('    ${e.key}: ${e.key},');
        }
      }
      sb.writeln('  );');
      sb.writeln('}\n');

      // Entity → Model
      sb.writeln('extension ${base}EntityExt on ${base}Entity {');
      sb.writeln('  ${base}Model toModel() => ${base}Model(');
      for (final e in fields.entries) {
        final f = e.value;
        if (f.isObjectRef) {
          sb.writeln('    ${e.key}: ${e.key}.toModel(),');
        } else if (f.isList && f.refClass != null) {
          sb.writeln(
              '    ${e.key}: ${e.key}.map((e) => e.toModel()).toList(),');
        } else {
          sb.writeln('    ${e.key}: ${e.key},');
        }
      }
      sb.writeln('  );');
      sb.writeln('}\n');
    }
    return sb.toString();
  }

  // ---------------- UTILITIES ----------------
  String _fieldDartType(FieldInfo info, {bool isEntity = false}) {
    if (info.isList) {
      if (info.listItemTypes.contains(FieldType.objectType) &&
          info.refClass != null) {
        final type = info.refClass! + (isEntity ? 'Entity' : 'Model');
        return 'List<$type>';
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

  String _toSnake(String name) => name
      .replaceAllMapped(RegExp('([a-z0-9])([A-Z])'), (m) => '${m[1]}_${m[2]}')
      .toLowerCase();
  String _toPascal(String name) =>
      name.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join();
  String _toCamel(String name) => name[0].toLowerCase() + name.substring(1);

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
