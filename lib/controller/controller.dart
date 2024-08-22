import 'package:arch/model/project_model.dart';

abstract class BaseController {
  final ProjectModel project;
  BaseController({required this.project});
}
