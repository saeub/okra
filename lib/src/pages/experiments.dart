import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../data/api.dart';
import '../data/models.dart';
import '../data/storage.dart';
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
  DateTime _lastUpdate;

  LinkedHashMap<Api, Future<List<Experiment>>> loadExperiments() {
    var storage = context.read<Storage>();
    var apis = <Api>[];
    apis.add(storage.tutorialApi);
    apis.addAll(storage.webApis);
    // apis.add(FakeApi());
    var experiments = LinkedHashMap<Api, Future<List<Experiment>>>.fromIterable(
        apis,
        key: (api) => api,
        value: (api) => api.getExperiments());

    _lastUpdate = DateTime.now();
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
            for (Api api in _experiments.keys)
              Column(
                key: ValueKey(api),
                children: [
                  ApiTitle(api),
                  FutureBuilder<List<Experiment>>(
                    future: _experiments[api],
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.isNotEmpty) {
                          return Column(
                            children: snapshot.data
                                .map((experiment) => ExperimentCard(
                                      experiment,
                                      lastUpdate: _lastUpdate,
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
                          );
                        } else {
                          return Column(
                            children: [
                              Icon(
                                Icons.assignment,
                                size: 50.0,
                                color: Colors.grey,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(S.of(context).experimentsNoTasks),
                              ),
                            ],
                          );
                        }
                      } else if (snapshot.hasError) {
                        return ErrorMessage(
                            S.of(context).errorGeneric(snapshot.error),
                            retry: () {
                          setState(() {
                            _experiments = loadExperiments();
                          });
                        });
                      } else {
                        return Column(children: [
                          CircularProgressIndicator(),
                        ]);
                      }
                    },
                  ),
                  Divider(),
                ],
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

class ExperimentCard extends StatefulWidget {
  final Experiment experiment;
  final DateTime lastUpdate;
  final GestureTapCallback onTap;

  const ExperimentCard(this.experiment, {this.lastUpdate, this.onTap, Key key})
      : super(key: key);

  @override
  _ExperimentCardState createState() => _ExperimentCardState();
}

class _ExperimentCardState extends State<ExperimentCard> {
  Future<int> _progressFuture;
  bool _disabled = false;

  Future<int> loadProgress() {
    return widget.experiment.nTasksDone().then((nTasksDone) {
      setState(() {
        _disabled = nTasksDone >= widget.experiment.nTasks;
      });
      return nTasksDone;
    });
  }

  @override
  void initState() {
    super.initState();
    _progressFuture = loadProgress();
  }

  @override
  void didUpdateWidget(ExperimentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lastUpdate != widget.lastUpdate) {
      _progressFuture = loadProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.experiment.coverImageUrl != null)
          Image.network(
            widget.experiment.coverImageUrl,
            height: 150.0,
            fit: BoxFit.cover,
          ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.experiment.title,
                  style: TextStyle(
                    fontSize: 20.0,
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FutureBuilder<int>(
                    future: _progressFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          S.of(context).experimentsTasksLeft(
                              widget.experiment.nTasks - snapshot.data),
                        );
                      } else if (snapshot.hasError) {
                        return Text(S.of(context).errorGeneric(snapshot.error));
                      } else {
                        return Text('');
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        FutureBuilder<int>(
          future: _progressFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return LinearProgressIndicator(
                  value: snapshot.data / widget.experiment.nTasks);
            } else if (snapshot.hasError) {
              return Text(S.of(context).errorGeneric(snapshot.error));
            } else {
              return LinearProgressIndicator();
            }
          },
        ),
      ],
    );

    if (_disabled) {
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
                onTap: _disabled ? null : widget.onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
