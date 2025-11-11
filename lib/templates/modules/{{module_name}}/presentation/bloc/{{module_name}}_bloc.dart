import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part '{{module_name}}_event.dart';
part '{{module_name}}_state.dart';

class {{class_name}}Bloc extends Bloc<{{class_name}}Event, {{class_name}}State> {
  {{class_name}}Bloc() : super({{class_name}}Initial()) {
    on<{{class_name}}Event>((event, emit) {
      // TODO: implement event handler
    });
  }
}
