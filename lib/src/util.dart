import 'package:flutter/material.dart';

import '../generated/l10n.dart';

typedef Translatable = String Function(S);

void showErrorSnackBar(BuildContext context, String message,
    {VoidCallback? retry}) {
  SnackBarAction? action;
  if (retry != null) {
    action = SnackBarAction(label: S.of(context).errorRetry, onPressed: retry);
  }
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    action: action,
  ));
}

class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? retry;

  const ErrorMessage(this.message, {this.retry, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(message),
        if (retry != null)
          TextButton.icon(
            icon: const Icon(Icons.refresh),
            label: Text(S.of(context).errorRetry),
            onPressed: retry,
          ),
      ],
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
      Key? key})
      : super(key: key);

  @override
  _AnimatedLinearProgressIndicatorState createState() =>
      _AnimatedLinearProgressIndicatorState();
}

class _AnimatedLinearProgressIndicatorState
    extends State<AnimatedLinearProgressIndicator> {
  late double _progress, _previousProgress;

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
    return TweenAnimationBuilder<double>(
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

class ReadingWidth extends StatelessWidget {
  final Widget child;

  const ReadingWidth({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700.0),
      child: child,
    );
  }
}

class FixationCross extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const FixationCross(
      {this.size = 30.0,
      this.color = const Color(0xFF616161),
      this.strokeWidth = 3.0,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FixationCrossPainter(color, strokeWidth),
      size: Size(size, size),
    );
  }
}

class _FixationCrossPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _FixationCrossPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;
    canvas.drawLine(
        Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
    canvas.drawLine(
        Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
  }

  @override
  bool shouldRepaint(_FixationCrossPainter oldDelegate) {
    return true;
  }
}
