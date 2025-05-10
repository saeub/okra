import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'generated/l10n.dart';
import 'src/colors.dart';
import 'src/data/storage.dart';
import 'src/pages/experiments.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('fonts/LICENSE.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  runApp(const App());
}

class App extends StatelessWidget {
  static final theme = ThemeData(
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary.shade600,
      error: AppColors.negative.shade700,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    textTheme: GoogleFonts.robotoTextTheme(),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      linearTrackColor: AppColors.primary.shade100,
    ),
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
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
  late Future<Storage> _storageFuture;

  @override
  void initState() {
    super.initState();
    _storageFuture = Storage.init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Storage>(
      future: _storageFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Storage storage = snapshot.data!;
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
