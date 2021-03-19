import 'package:flutter/widgets.dart';
import 'qr_native.dart' if (dart.library.html) 'qr_web.dart';

Future<String> scanQrCode(BuildContext context) async {
  return await scan(context);
}

class QrScanError implements Exception {
  final String message;

  QrScanError(this.message);

  @override
  String toString() {
    return message;
  }
}
