import 'package:arch/controller/build.dart';
import 'package:arch/generator/generator.dart';

class BuildGenerator extends BaseGenerator {
  final BuildController controller;
  BuildGenerator({
    required this.controller,
  });

  @override
  Future<void> call(List<String> arguments) {
    // TODO: implement call
    throw UnimplementedError();
  }
}
