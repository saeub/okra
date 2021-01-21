import 'dart:collection';

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

class ExperimentsMenuPage extends StatefulWidget {
  ExperimentsMenuPage();

  @override
  _ExperimentsMenuPageState createState() => _ExperimentsMenuPageState();
}

class _ExperimentsMenuPageState extends State<ExperimentsMenuPage> {
  LinkedHashMap<Api, Future<List<Experiment>>> _experiments;

  LinkedHashMap<Api, Future<List<Experiment>>> loadExperiments() {
    var storage = context.read<Storage>();
    var apis = <Api>[];
    apis.add(storage.tutorialApi);
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
              icon: Icon(Icons.settings),
              tooltip: S.of(context).settingsPageTitle,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider.value(
                          value: storage, child: SettingsPage())),
                );
                setState(() {
                  _experiments = loadExperiments();
                });
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        child: ListView(
          children: [
            for (var api in _experiments.keys)
              FutureBuilder<List<Experiment>>(
                future: _experiments[api],
                builder: (context, snapshot) {
                  Widget content;
                  if (snapshot.hasData) {
                    var visibleExperiments = snapshot.data.where((experiment) =>
                        storage.showCompleted ||
                        experiment.nTasksDone < experiment.nTasks);
                    if (visibleExperiments.isNotEmpty) {
                      content = Column(
                        children: [
                          ...visibleExperiments
                              .map((experiment) => ExperimentCard(
                                    experiment,
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TaskPage(experiment),
                                        ),
                                      );
                                      setState(() {
                                        _experiments = loadExperiments();
                                      });
                                    },
                                    key: ValueKey<String>(experiment.id),
                                  ))
                              .toList(),
                        ],
                      );
                    } else if (api is TutorialApi) {
                      content = null;
                    } else {
                      content = Column(children: [
                        Icon(
                          Icons.assignment,
                          size: 50.0,
                          color: Colors.grey,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(S.of(context).experimentsNoTasks),
                        ),
                      ]);
                    }
                  } else if (snapshot.hasError) {
                    content = ErrorMessage(
                        S.of(context).errorGeneric(snapshot.error), retry: () {
                      setState(() {
                        _experiments = loadExperiments();
                      });
                    });
                  } else {
                    content = Column(
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
                            Divider(),
                          ]
                        : [],
                  );
                },
              ),
          ],
        ),
        onRefresh: () async {
          setState(() {
            _experiments = loadExperiments();
          });
          await Future.wait(_experiments.values);
        },
      ),
    );
  }
}

class ApiTitle extends StatelessWidget {
  final Api api;

  const ApiTitle(this.api, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          SizedBox(
            child: api.getIcon(),
            height: 40.0,
          ),
          Flexible(
            child: Text(
              api.getName(),
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        ],
      ),
    );
  }
}

class ExperimentCard extends StatelessWidget {
  final Experiment experiment;
  final GestureTapCallback onTap;

  const ExperimentCard(this.experiment, {this.onTap, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (experiment.coverImageUrl != null)
          Image.network(
            experiment.coverImageUrl,
            height: 150.0,
            fit: BoxFit.cover,
          ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(experiment.title,
                  style: TextStyle(
                    fontSize: 20.0,
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    S.of(context).experimentsTasksLeft(
                        experiment.nTasks - experiment.nTasksDone),
                  )
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
        colorFilter: ColorFilter.mode(Colors.white, BlendMode.saturation),
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
                splashColor: Theme.of(context).accentColor.withOpacity(0.5),
                onTap: enabled ? onTap : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
