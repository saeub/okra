import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../generated/l10n.dart';
import '../data/api.dart';
import '../util.dart';

class RegistrationData {
  final String url;
  final String participantId;
  final String registrationKey;

  const RegistrationData(this.url, this.participantId, this.registrationKey);
}

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  TextEditingController _urlController = TextEditingController();
  late TextEditingController _participantIdController;
  late TextEditingController _registrationKeyController;
  late bool _loading;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    _participantIdController = TextEditingController();
    _registrationKeyController = TextEditingController();
    _loading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).registrationPageTitle),
      ),
      body: Builder(
        builder: (context) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: S.of(context).registrationUrl,
                  ),
                ),
                TextField(
                  controller: _participantIdController,
                  decoration: InputDecoration(
                    labelText: S.of(context).registrationParticipantId,
                  ),
                ),
                TextField(
                  controller: _registrationKeyController,
                  decoration: InputDecoration(
                    labelText: S.of(context).registrationKey,
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: Text(S.of(context).registrationOk),
                      onPressed: _loading ? null : () => register(context),
                    ),
                    Visibility(
                      visible: _loading,
                      child: Container(
                        height: 40,
                        width: 40,
                        padding: const EdgeInsets.all(8.0),
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton.extended(
          icon: const Icon(Icons.camera_alt),
          label: Text(S.of(context).registrationScanQrCode),
          onPressed: () async {
            try {
              var registrationData = await Navigator.of(context)
                  .push<RegistrationData>(MaterialPageRoute(
                      builder: (context) => const RegistrationCodeScanner()));
              if (registrationData != null) {
                _urlController.text = registrationData.url;
                _participantIdController.text = registrationData.participantId;
                _registrationKeyController.text =
                    registrationData.registrationKey;
              }
            } on QrScanError catch (e) {
              showErrorSnackBar(context, e.message);
            } catch (_) {
              // TODO: Report error
              showErrorSnackBar(context, S.of(context).errorUnknown);
            }
          },
        ),
      ),
    );
  }

  Future<void> register(BuildContext context) async {
    try {
      setState(() {
        _loading = true;
      });
      var api = await WebApi.register(_urlController.text,
          _participantIdController.text, _registrationKeyController.text);
      Navigator.of(context).pop<WebApi>(api);
    } on ApiError catch (e) {
      setState(() {
        _loading = false;
      });
      showErrorSnackBar(
        context,
        e.message(S.of(context)),
        retry: e.retriable ? () => register(context) : null,
      );
    } catch (_) {
      setState(() {
        _loading = false;
      });
      // TODO: Report error
      showErrorSnackBar(
        context,
        S.of(context).errorUnknown,
        retry: () => register(context),
      );
    }
  }
}

class RegistrationCodeScanner extends StatelessWidget {
  const RegistrationCodeScanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).registrationQrScannerTitle)),
      body: MobileScanner(
        onDetect: (barcode) {
          var data = barcode.raw.split('\n');
          if (data == null || data.length != 3) {
            throw QrScanError(S.of(context).registrationInvalidQrCode);
          }
          Navigator.of(context)
              .pop(RegistrationData(data[0], data[1], data[2]));
        },
      ),
    );
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
