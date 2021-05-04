import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import 'generated/l10n.dart';
import 'src/data/storage.dart';
import 'src/pages/experiments.dart';

var testMode = false;

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Okra',
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: Colors.green[600],
      ),
      home: StorageWrapper(),
      localizationsDelegates: <LocalizationsDelegate>[
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
    );
  }
}

class StorageWrapper extends StatefulWidget {
  @override
  _StorageWrapperState createState() => _StorageWrapperState();
}

class _StorageWrapperState extends State<StorageWrapper> {
  Future<LocalStorage> _localStorageFuture;

  @override
  void initState() {
    super.initState();
    _localStorageFuture = Storage.loadLocalStorage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LocalStorage>(
      future: _localStorageFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Storage storage;
          try {
            storage = Storage(snapshot.data);
          } on IncompatibleStorageError catch (e) {
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('An error occurred while loading storage: $e\n\n'
                        'We are unable to resolve this issue. '
                        'You can try deleting all stored settings and data and starting from scratch. '
                        'You will have to add your APIs again. '
                        'Contact your API provider for more information.\n\n'
                        'Alternatively, exit the app and try downgrading it.\n'),
                    Text(
                      'Delete all data now?',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.delete),
                      label: Text('YES, DELETE'),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.red),
                      ),
                      // color: Colors.red,
                      // textColor: Colors.white,
                      onPressed: () async {
                        await snapshot.data.clear();
                        setState(() {
                          _localStorageFuture = Storage.loadLocalStorage();
                        });
                      },
                    )
                  ],
                ),
              ),
            );
          }
          return ChangeNotifierProvider.value(
            value: storage,
            child: ExperimentsMenuPage(),
          );
        } else if (snapshot.hasError) {
          return Center(
              child: Text(S.of(context).errorGeneric(snapshot.error)));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
