import 'package:flutter/widgets.dart';
import 'package:okra/src/pages/registration.dart';

import '../../generated/l10n.dart';
import 'qr_native.dart' if (dart.library.html) 'qr_web.dart';

Future<RegistrationData> scanRegistrationCode(BuildContext context) async {
  var result = await scan(context);
  var data = result.split('\n');
  if (data.length == 3) {
    return RegistrationData(data[0], data[1], data[2]);
  } else {
    throw QrScanError(S.of(context).registrationInvalidQrCode);
  }
}

class QrScanError implements Exception {
  final String message;

  QrScanError(this.message);

  @override
  String toString() {
    return message;
  }
}
