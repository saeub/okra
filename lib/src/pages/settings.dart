import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
          for (WebApi api in storage.webApis)
            ListTile(
              title: Text('${api.name} (${api.baseUrl})'),
              subtitle: Text(S.of(context).settingsApiDate(
                  DateFormat.yMd().format(api.added),
                  DateFormat.Hm().format(api.added))),
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
                        FlatButton(
                          child: Text(S.of(context).dialogNo),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        FlatButton(
                          child: Text(S.of(context).dialogYes),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
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
                    FlatButton(
                      child: Text(S.of(context).dialogNo),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    FlatButton(
                      child: Text(S.of(context).dialogYes),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
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
          AboutListTile(
            icon: Icon(Icons.info),
            aboutBoxChildren: [
              Text(S.of(context).settingsAboutText),
            ],
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
