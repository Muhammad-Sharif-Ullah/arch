import 'package:arch/model/project_model.dart';
import 'package:interact/interact.dart' show Select;

List<String> license = [
  'Apache License 2.0',
  'MIT License',
  'BSD 2-Clause "Simplified" License',
  'Generate Custom',
  'Unlicense',
];

class LicenseController {
  Future<void> call({
    required final ProjectModel projectModel,
    required String? onSelectedLicense,
  }) async {
    // Get the project license
    // Get License
    if (onSelectedLicense == null) {
      final int licenseIndex = Select(
        prompt: 'Select License',
        options: license,
        initialIndex: 0,
      ).interact();
      onSelectedLicense = license[licenseIndex];
    }
    await generate(onSelectedLicense, projectModel);
  }

  Future<void> generate(
      final String selectedLicense, final ProjectModel projectModel) async {
    // Generate License
    final licenseContent = '''
MIT License

Copyright (c) 2024 Your Company

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
''';
  }
}
