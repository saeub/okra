import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../data/api.dart';
import '../data/models.dart';
import '../data/storage.dart';
import '../data/tutorial.dart';
import '../pages/settings.dart';
import '../pages/task.dart';
import '../util.dart';
import 'registration.dart';

class ExperimentsMenuPage extends StatefulWidget {
  const ExperimentsMenuPage({Key? key}) : super(key: key);

  @override
  _ExperimentsMenuPageState createState() => _ExperimentsMenuPageState();
}

class _ExperimentsMenuPageState extends State<ExperimentsMenuPage> {
  late LinkedHashMap<Api, Future<List<Experiment>>> _experiments;

  LinkedHashMap<Api, Future<List<Experiment>>> loadExperiments() {
    var storage = context.read<Storage>();
    var apis = <Api>[];
    // apis.add(storage.tutorialApi);
    apis.addAll(storage.webApis);
    var experiments = LinkedHashMap<Api, Future<List<Experiment>>>.fromIterable(
        apis,
        key: (api) => api,
        value: (api) => api.getExperiments());
    return experiments;
  }

  @override
  void initState() {
    super.initState();
    _experiments = loadExperiments();
  }

  @override
  Widget build(BuildContext context) {
    var storage = context.watch<Storage>();
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).experimentsPageTitle),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.settings),
              tooltip: S.of(context).settingsPageTitle,
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider.value(
                          value: storage, child: const SettingsPage())),
                );
                setState(() {
                  _experiments = loadExperiments();
                });
              },
            ),
          ),
        ],
      ),
      body: storage.webApis.isEmpty
          ? buildIntro(context)
          : buildExperimentsList(context, storage.showCompleted),
    );
  }

  Widget buildIntro(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ReadingWidth(
              width: 400.0,
              child: Text(S.of(context).experimentsIntro,
                  style: const TextStyle(color: Colors.black, fontSize: 18.0)),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  var registrationData = await Navigator.of(context)
                      .push<RegistrationData>(MaterialPageRoute(
                          builder: (context) =>
                              const RegistrationCodeScanner()));
                  if (registrationData != null) {
                    var api = await WebApi.register(
                        registrationData.url,
                        registrationData.participantId,
                        registrationData.registrationKey);
                    context.read<Storage>().addWebApi(api);
                    setState(() {
                      _experiments = loadExperiments();
                    });
                  }
                } on QrScanError catch (e) {
                  showErrorSnackBar(context, e.message);
                } on ApiError catch (e) {
                  showErrorSnackBar(
                    context,
                    e.message(S.of(context)),
                  );
                } catch (_) {
                  // TODO: Report error
                  showErrorSnackBar(context, S.of(context).errorUnknown);
                }
              },
              icon: const Icon(Icons.camera_alt),
              label: Text(S.of(context).experimentsScanQrCode),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildExperimentsList(BuildContext context, bool showCompleted) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _experiments = loadExperiments();
        });
        await Future.wait(_experiments.values);
      },
      child: ListView(
        children: [
          for (var api in _experiments.keys)
            FutureBuilder<List<Experiment>>(
              future: _experiments[api],
              builder: (context, snapshot) {
                Widget? content;
                if (snapshot.hasData) {
                  var visibleExperiments = snapshot.data!
                      .where((experiment) =>
                          showCompleted ||
                          experiment.nTasksDone < experiment.nTasks)
                      .toList();
                  if (visibleExperiments.isNotEmpty) {
                    content = LayoutBuilder(builder: (context, constraints) {
                      var nColumns = max(constraints.maxWidth ~/ 400.0, 1);
                      var columns = List<List<ExperimentCard>>.generate(
                          nColumns, (_) => []);
                      for (var i = 0; i < visibleExperiments.length; i++) {
                        columns[i % nColumns].add(ExperimentCard(
                          visibleExperiments[i],
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    TaskPage(visibleExperiments[i]),
                              ),
                            );
                            setState(() {
                              _experiments = loadExperiments();
                            });
                          },
                          key: ValueKey<String>(visibleExperiments[i].id),
                        ));
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var column in columns)
                            Expanded(
                              child: Column(
                                children: column,
                              ),
                            ),
                        ],
                      );
                    });
                  } else if (api is TutorialApi) {
                    content = null;
                  } else {
                    content = Column(children: [
                      Icon(
                        Icons.assignment,
                        size: 50.0,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(S.of(context).experimentsNoTasks),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: Text(S.of(context).experimentsRefresh),
                        onPressed: () async {
                          setState(() {
                            _experiments = loadExperiments();
                          });
                          await Future.wait(_experiments.values);
                        },
                      ),
                    ]);
                  }
                } else if (snapshot.hasError) {
                  content = ErrorMessage(
                      S.of(context).errorGeneric(snapshot.error!), retry: () {
                    setState(() {
                      _experiments = loadExperiments();
                    });
                  });
                } else {
                  content = const Column(
                    children: [
                      CircularProgressIndicator(),
                    ],
                  );
                }
                return Column(
                  key: ValueKey(api),
                  children: content != null
                      ? [
                          ApiTitle(api),
                          content,
                          const Divider(),
                        ]
                      : [],
                );
              },
            ),
        ],
      ),
    );
  }
}

class ApiTitle extends StatelessWidget {
  final Api api;

  const ApiTitle(this.api, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0),
            child: SizedBox(
              height: 30.0,
              child: api.getIcon(),
            ),
          ),
          Flexible(
            child: Text(
              api.getName(),
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class ExperimentCard extends StatelessWidget {
  final Experiment experiment;
  final GestureTapCallback? onTap;

  const ExperimentCard(this.experiment, {this.onTap, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var coverImageUrl = experiment.coverImageUrl;
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 150.0,
          child: coverImageUrl != null
              ? Image.network(
                  coverImageUrl,
                  fit: BoxFit.cover,
                )
              : ClipRect(
                  child: Center(
                    child: Transform.translate(
                      offset: const Offset(0, -25.0),
                      child: Transform.rotate(
                        angle: -0.3,
                        child: Icon(
                          experiment.type.icon,
                          size: 200.0,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.4),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(experiment.title,
                        style: const TextStyle(
                          fontSize: 20.0,
                        )),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(S.of(context).experimentsStart),
                      ),
                      Text(
                        S.of(context).experimentsTasksLeft(
                            experiment.nTasks - experiment.nTasksDone),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        LinearProgressIndicator(
            value: experiment.nTasksDone / experiment.nTasks, minHeight: 8.0)
      ],
    );

    var enabled = experiment.nTasksDone < experiment.nTasks;
    if (!enabled) {
      content = ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.saturation),
        child: content,
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          content,
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                highlightColor: Colors.transparent,
                splashColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.4),
                onTap: enabled ? onTap : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
