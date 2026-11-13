import 'package:flutter/services.dart';

/// Encodes a Flutter keyboard request for the native Compose text fields.
String androidM3EKeyboardTypeName(
  TextInputType? type, {
  bool multiline = false,
}) {
  final resolved =
      type ?? (multiline ? TextInputType.multiline : TextInputType.text);
  if (resolved.index == TextInputType.number.index) {
    if (resolved.decimal == true) {
      return resolved.signed == true ? 'decimalSigned' : 'decimal';
    }
    return resolved.signed == true ? 'numberSigned' : 'number';
  }
  if (resolved == TextInputType.phone) return 'phone';
  if (resolved == TextInputType.datetime) return 'dateTime';
  if (resolved == TextInputType.emailAddress) return 'email';
  if (resolved == TextInputType.url || resolved == TextInputType.webSearch) {
    return 'url';
  }
  if (resolved == TextInputType.twitter) return 'email';
  if (resolved == TextInputType.visiblePassword) return 'passwordVisible';
  if (resolved == TextInputType.name) return 'personName';
  if (resolved == TextInputType.streetAddress) return 'postalAddress';
  if (resolved == TextInputType.multiline) return 'multiline';
  return 'text';
}
