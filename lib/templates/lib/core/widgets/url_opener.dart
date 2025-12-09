import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Opener {
  static Opener? _instance;
  // Avoid self instance
  Opener._();
  static Opener get instance => _instance ??= Opener._();

  // phone number open method
  static void openPhoneNumber({
    required String phoneNumber,
    required BuildContext context,
  }) {
    // open phone number
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      launchUrl(phoneUri);
    } on Exception {
      // TaskNotifier.instance.info(context, message: e.toString());
    }
  }

  // email open method
  void openEmail({required String email, required BuildContext context}) {
    // open email
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    try {
      launchUrl(emailUri);
    } on Exception {
      // TaskNotifier.instance.info.call(context, message: e.toString());
    }
  }

  // url open method
  void openUrl({required String url, required BuildContext context}) {
    // open url
    final Uri urlUri = Uri(scheme: 'https', path: url);
    try {
      launchUrl(urlUri);
    } on Exception {
      // TaskNotifier.instance.info.call(context, message: e.toString());
    }
  }
}
