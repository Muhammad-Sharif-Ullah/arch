import 'package:json_annotation/json_annotation.dart';
import 'package:{{project_name}}/features/onboarding/domain/entities/onboading.dart';

part '../../../../../../lib/features/onboarding/data/models/onbading.g.dart';

@JsonSerializable()
class OnboadingModel extends OnboadingEntity {
  const OnboadingModel({
    required super.title,
    required super.subtitle,
    required super.image,
    required super.id,
  });

  factory OnboadingModel.fromJson(Map<String, dynamic> json) =>
      _$OnboadingModelFromJson(json);
  Map<String, dynamic> toJson() => _$OnboadingModelToJson(this);
}
