import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../data/api.dart';
import '../data/storage.dart';
import 'registration.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage();

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    var storage = context.watch<Storage>();
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settingsPageTitle),
      ),
      body: ListView(
        children: [
          ListHeadingTile(S.of(context).settingsApiHeading),
          for (var api in storage.webApis)
            ListTile(
              title: Text('${api.name} (${api.baseUrl})'),
              subtitle: Text(S.of(context).settingsApiDate(
                      DateFormat.yMd().format(api.added),
                      DateFormat.Hm().format(api.added)) +
                  ' (ID: ${api.participantId})'),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                tooltip: S.of(context).settingsDeleteApi,
                onPressed: () async {
                  var confirmed = await showDialog<bool>(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(S.of(context).settingsDeleteApiDialogTitle),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text(S.of(context).dialogNo),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text(S.of(context).dialogYes),
                        ),
                      ],
                    ),
                  );
                  if (confirmed) {
                    storage.removeWebApi(api);
                  }
                },
              ),
            ),
          ListTile(
            leading: Icon(Icons.add),
            title: Text(S.of(context).settingsAddApi),
            onTap: () async {
              var newApi = await Navigator.push<WebApi>(context,
                  MaterialPageRoute(builder: (context) => RegistrationPage()));
              if (newApi != null) {
                storage.addWebApi(newApi);
              }
            },
          ),
          CheckboxListTile(
            title: Text('Show completed experiments'),
            value: storage.showCompleted,
            onChanged: storage.setShowCompleted,
          ),
          Divider(),
          ListHeadingTile(S.of(context).settingsTutorialHeading),
          ListTile(
            leading: Icon(Icons.undo),
            title: Text(S.of(context).settingsResetTutorial),
            enabled: storage.tutorialApi.isResettable(),
            onTap: () async {
              var confirmed = await showDialog<bool>(
                barrierDismissible: false,
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(S.of(context).settingsResetTutorialDialogTitle),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Text(S.of(context).dialogNo),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: Text(S.of(context).dialogYes),
                    ),
                  ],
                ),
              );
              if (confirmed) {
                storage.resetTutorial();
              }
            },
          ),
          Divider(),
          ListHeadingTile(S.of(context).settingsAboutHeading),
          FutureBuilder<PackageInfo>(
            future: _packageInfoFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return AboutListTile(
                  icon: Icon(Icons.info),
                  applicationVersion: snapshot.data.version,
                  aboutBoxChildren: [
                    Text(S.of(context).settingsAboutText),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ],
      ),
    );
  }
}

class ListHeadingTile extends StatelessWidget {
  final String text;

  const ListHeadingTile(this.text);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        text,
        style: Theme.of(context).textTheme.subtitle2,
      ),
      dense: true,
    );
  }
}
