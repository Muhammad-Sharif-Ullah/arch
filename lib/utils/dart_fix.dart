import 'dart:io';

class DartFix {
  DartFix._();

  static Future<void> fixer() async {
    try {
      // Run dart format .
      final formatResult = await Process.run('dart', ['format', '.']);
      stdout.write(formatResult.stdout);
      stderr.write(formatResult.stderr);

      // Run dart fix --apply
      final fixResult = await Process.run('dart', ['fix', '--apply']);
      stdout.write(fixResult.stdout);
      stderr.write(fixResult.stderr);

      print('✅ Dart format and fixes applied successfully!');
    } catch (e) {
      print('❌ Error: $e');
    }
  }
}
