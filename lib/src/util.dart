import 'package:flutter/material.dart';

import '../generated/l10n.dart';

typedef Translatable = String Function(S);

void showErrorSnackBar(BuildContext context, String message,
    {VoidCallback retry}) {
  SnackBarAction action;
  if (retry != null) {
    action = SnackBarAction(label: S.of(context).errorRetry, onPressed: retry);
  }
  Scaffold.of(context).showSnackBar(SnackBar(
    content: Text(message),
    action: action,
  ));
}

class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback retry;

  const ErrorMessage(this.message, {this.retry, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(message),
        if (retry != null)
          FlatButton.icon(
            icon: Icon(Icons.refresh),
            label: Text(S.of(context).errorRetry),
            onPressed: retry,
          ),
      ],
    );
  }
}

class AccentButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const AccentButton(this.icon, this.text,
      {this.color, this.onPressed, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton.icon(
      icon: Icon(icon),
      label: Text(text),
      color: color ?? Theme.of(context).accentColor,
      textColor: Theme.of(context).accentTextTheme.button.color,
      onPressed: onPressed,
    );
  }
}

class AnimatedLinearProgressIndicator extends StatefulWidget {
  final double progress;
  final Duration duration;
  final double height;

  const AnimatedLinearProgressIndicator(this.progress,
      {this.duration = const Duration(milliseconds: 300),
      this.height = 8.0,
      Key key})
      : super(key: key);

  @override
  _AnimatedLinearProgressIndicatorState createState() =>
      _AnimatedLinearProgressIndicatorState();
}

class _AnimatedLinearProgressIndicatorState
    extends State<AnimatedLinearProgressIndicator> {
  double _progress, _previousProgress;

  @override
  void initState() {
    super.initState();
    _progress = widget.progress;
    _previousProgress = _progress;
  }

  @override
  void didUpdateWidget(AnimatedLinearProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      setState(() {
        _progress = widget.progress;
        _previousProgress = oldWidget.progress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: _previousProgress, end: _progress),
      duration: widget.duration,
      builder: (context, progress, _) {
        return LinearProgressIndicator(
          value: progress,
          minHeight: widget.height,
        );
      },
    );
  }
}
