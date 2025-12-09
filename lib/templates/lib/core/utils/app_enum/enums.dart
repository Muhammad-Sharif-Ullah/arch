import 'package:json_annotation/json_annotation.dart';

@JsonEnum() // enables string-based serialization by default
enum DiscountEnum {
  @JsonValue('flat')
  flat,
  @JsonValue('percentage')
  percentage,
}

@JsonEnum() // enables string-based serialization by default
enum OtpVerificaitonType {
  @JsonValue('registration')
  registration,
  @JsonValue('forgot-password')
  forgotPassword,
  @JsonValue('reset-password')
  resetPassword,
}

@JsonEnum() // enables string-based serialization by default
enum VerificationMedium {
  @JsonValue('email')
  email,
  @JsonValue('phone')
  phone,
}

@JsonEnum() // enables string-based serialization by default
enum Gender {
  @JsonValue('male')
  male,
  @JsonValue('femal')
  femal,
}
