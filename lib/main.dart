import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import 'generated/l10n.dart';
import 'src/colors.dart';
import 'src/data/storage.dart';
import 'src/pages/experiments.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  static final theme = ThemeData(
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary.shade600,
      error: AppColors.negative.shade700,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      linearTrackColor: AppColors.primary.shade100,
    ),
  );

  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Okra',
      theme: theme,
      home: const StorageWrapper(child: ExperimentsMenuPage()),
      localizationsDelegates: const <LocalizationsDelegate>[
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
  final Widget child;

  const StorageWrapper({required this.child, Key? key}) : super(key: key);

  @override
  _StorageWrapperState createState() => _StorageWrapperState();
}

class _StorageWrapperState extends State<StorageWrapper> {
  late Future<LocalStorage> _localStorageFuture;

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
            storage = Storage(snapshot.data!);
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
                      icon: const Icon(Icons.delete),
                      label: const Text('YES, DELETE'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Theme.of(context).colorScheme.error),
                      ),
                      onPressed: () async {
                        await snapshot.data!.clear();
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
            child: widget.child,
          );
        } else if (snapshot.hasError) {
          return Center(
              child: Text(S.of(context).errorGeneric(snapshot.error!)));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
