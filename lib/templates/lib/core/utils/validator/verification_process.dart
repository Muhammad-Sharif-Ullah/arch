import 'package:{{project_name}}/core/widgets/phone_number/country.dart';

abstract class VerificationProcess {
  VerificationProcess();
}

class PhoneVerification extends VerificationProcess {
  final Country country;

  PhoneVerification({required this.country});

  Map<String, dynamic> toJson() => country.toJson();

  factory PhoneVerification.fromJson(Map<String, dynamic> json) =>
      PhoneVerification(country: Country.fromJson(json));
}

class EmailVerification extends VerificationProcess {
  final String email;

  EmailVerification({required this.email});

  Map<String, dynamic> toJson() => {"email": email};
  factory EmailVerification.fromJson(Map<String, dynamic> json) =>
      EmailVerification(email: json['email'] as String);
}
