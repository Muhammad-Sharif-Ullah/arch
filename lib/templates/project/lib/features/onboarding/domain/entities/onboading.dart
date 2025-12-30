import 'package:equatable/equatable.dart';

class OnboadingEntity extends Equatable {
  final int id;
  final String title;
  final String subtitle;
  final String image;

  const OnboadingEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
  });

  @override
  List<Object?> get props => [title, image, subtitle, id];
}
