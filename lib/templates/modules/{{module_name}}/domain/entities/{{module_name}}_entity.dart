
import 'package:equatable/equatable.dart';

class {{class_name}}Entity  extends Equatable {

  final String name;

  const {{class_name}}Entity({required this.name});


  @override
  List<Object> get props => [name];
  
}