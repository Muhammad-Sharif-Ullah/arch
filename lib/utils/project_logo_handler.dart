import 'dart:io';

import 'package:arch_cli/model/project_model.dart';

class ProjectLogoHandler {
  static Future<void> handleProjectLogo(ProjectModel project) async {
    final logoPath = project.logoPath;

    // If no logo provided, we just leave the default assets (which come from the template).
    if (logoPath == null || logoPath.trim().isEmpty) {
      return;
    }

    // We are already inside project_dir
    final iconsDir = Directory('assets/icons');

    if (iconsDir.existsSync()) {
      // Clear existing default icons (like logo.png) so we only have the new one
      for (final entity in iconsDir.listSync()) {
        entity.deleteSync();
      }
    } else {
      iconsDir.createSync(recursive: true);
    }

    final targetFile = File('${iconsDir.path}/logo.png');

    try {
      if (_isNetworkUrl(logoPath)) {
        await _downloadLogo(logoPath, targetFile);
      } else {
        await _copyLocalLogo(logoPath, targetFile);
      }

      print('🖼 Logo added → ${targetFile.path}');
    } catch (e) {
      print('⚠️ Logo setup failed (${e.toString()})');
    }
  }

  // ---------------- Helpers ----------------

  static bool _isNetworkUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme.startsWith('http') || uri.scheme.startsWith('https'));
  }

  static Future<void> _copyLocalLogo(
    String sourcePath,
    File target,
  ) async {
    final source = File(sourcePath);

    if (!source.existsSync()) {
      throw Exception('Local logo file not found');
    }

    await source.copy(target.path);
  }

  static Future<void> _downloadLogo(
    String url,
    File target,
  ) async {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();

    if (response.statusCode != 200) {
      throw Exception('Failed to download logo (HTTP ${response.statusCode})');
    }

    await response.pipe(target.openWrite());
  }
}
