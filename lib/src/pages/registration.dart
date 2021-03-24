import 'package:flutter/material.dart';
import 'package:okra/src/qr/qr.dart';

import '../../generated/l10n.dart';
import '../data/api.dart';
import '../qr/qr.dart';
import '../util.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  TextEditingController _urlController = TextEditingController();
  TextEditingController _participantIdController;
  TextEditingController _registrationKeyController;
  bool _loading;

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
            padding: EdgeInsets.all(8.0),
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
                      icon: Icon(Icons.check),
                      label: Text(S.of(context).registrationOk),
                      onPressed: _loading ? null : () => register(context),
                    ),
                    Visibility(
                      visible: _loading,
                      child: Container(
                        height: 40,
                        width: 40,
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
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
          icon: Icon(Icons.camera_alt),
          label: Text(S.of(context).registrationScanQrCode),
          onPressed: () async {
            try {
              var result = await scanQrCode(context);
              var data = result.split('\n');
              if (data.length == 3) {
                _urlController.text = data[0];
                _participantIdController.text = data[1];
                _registrationKeyController.text = data[2];
              } else {
                showErrorSnackBar(
                    context, S.of(context).registrationInvalidQrCode);
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
      Navigator.pop<WebApi>(context, api);
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
