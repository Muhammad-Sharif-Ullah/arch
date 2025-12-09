import 'package:intl/intl.dart';

extension Currency<T> on T {
  String currency(String? name) {
    final String symbol = NumberFormat.simpleCurrency(
      name: name ?? "BDT",
    ).currencySymbol;
    return "$symbol$this";
  }
}

/// String ext
///

extension StringExt on String {
  bool isOnline() => startsWith('http://') || startsWith('https://');
}
