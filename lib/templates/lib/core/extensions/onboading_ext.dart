// ==========================================================
// Auto-generated model <-> entity extensions for module: onboading
// ==========================================================

// ----------------------------------------------------------
// Converters for Onboading
// ----------------------------------------------------------

import 'package:{{project_name}}/features/onboarding/data/models/onbading.dart';
import 'package:{{project_name}}/features/onboarding/domain/entities/onboading.dart';

extension OnboadingModelExt on OnboadingModel {
  OnboadingEntity toEntity() =>
      OnboadingEntity(id: id, title: title, subtitle: subtitle, image: image);
}

extension OnboadingEntityExt on OnboadingEntity {
  OnboadingModel toModel() =>
      OnboadingModel(id: id, title: title, subtitle: subtitle, image: image);
}
