import 'package:arch/arch.dart';
import 'package:mustache_template/mustache.dart';

class LogoGeneratorController {
  Future<void> generate({
    required final String iconColor,
    required final String backgroundColor,
  }) async {
    final svgPath = "lib/templates/assets/images/ic_launcher.svg";
    final templateString = await readContent(path: svgPath);
    final template = Template(templateString);
    final injectionData = {
      'iconColor': iconColor,
      'backgroundColor': backgroundColor,
    };
    final svgString = template.renderString(injectionData);
    // final SvgPicture logSvg = SvgPicture.string(svgString);

    // save the svg file
    writeFile(
      path: "lib/templates/assets/images/ic_launcher-1.svg",
      content: svgString,
    );

    final pythonCodePath = "lib/templates/python/exe";

    await runCommand('$pythonCodePath', []);
  }
}
// ./exe ../assets/images/ic_launcher-1.svg ../assets/images/ic_launcher-1.png