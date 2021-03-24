import 'package:flutter/widgets.dart';
import 'package:tekartik_qrscan_flutter_web/qrscan_flutter_web.dart';

Future<String> scan(BuildContext context) async {
  return await scanQrCode(context);
}
