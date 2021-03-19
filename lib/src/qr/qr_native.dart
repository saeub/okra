import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:okra/src/qr/qr.dart';

import '../../generated/l10n.dart';

Future<String> scan(BuildContext context) async {
  ScanResult result;
  try {
    result = await BarcodeScanner.scan(
      options: ScanOptions(restrictFormat: [
        BarcodeFormat.qr,
      ], strings: {
        'cancel': S.of(context).registrationQrCancel,
        'flash_on': S.of(context).registrationQrFlashOn,
        'flash_off': S.of(context).registrationQrFlashOff,
      }),
    );
  } on PlatformException {
    throw QrScanError(S.of(context).registrationCameraPermissionRequired);
  }
  if (result.type == ResultType.Error) {
    throw result.rawContent;
  }
  return result.rawContent;
}
