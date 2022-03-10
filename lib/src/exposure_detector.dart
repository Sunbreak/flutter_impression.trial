import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

///
/// Inspired by [_TabControllerScope]
/// 
class _ExposureInheritedScope extends InheritedWidget {
  _ExposureInheritedScope({
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  final Map<String, Timer?> timers = {};

  static _ExposureInheritedScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ExposureInheritedScope>()!;
  }

  @override
  bool updateShouldNotify(_ExposureInheritedScope old) {
    return timers != old.timers;
  }
}

/// 
/// Inspired by [DefaultTabController]
/// 
class ExposureBoundary extends StatefulWidget {
  const ExposureBoundary({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  State<StatefulWidget> createState() => _ExposureBoundaryState();
}

class _ExposureBoundaryState extends State<ExposureBoundary> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _ExposureInheritedScope(
      child: widget.child,
    );
  }
}

/// 
/// Inspired by [TabBar]
/// 
class ExposureDetector extends StatefulWidget {
  ExposureDetector({
    required String exposureKey,
    required this.child,
    required this.onImpress,
    this.threshold = const Duration(milliseconds: 200),
  }) : super(key: Key(exposureKey));

  String get exposureKey => (key as ValueKey).value;

  final VisibilityChangedCallback onImpress;

  final Widget child;

  final Duration threshold;

  @override
  State<StatefulWidget> createState() => _ExposureDetectorState();
}

class _ExposureDetectorState extends State<ExposureDetector> {
  Map<String, Timer?>? _timers;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timers = _ExposureInheritedScope.of(context).timers;
  }

  @override
  void didUpdateWidget(ExposureDetector oldWidget) {
    super.didUpdateWidget(oldWidget);
    _timers = _ExposureInheritedScope.of(context).timers;
  }

  @override
  void dispose() {
    _timers = null;
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: widget.key!,
      child: widget.child,
      onVisibilityChanged: _handleVisibilityChanged,
    );
  }

  void _handleVisibilityChanged(VisibilityInfo visibilityInfo) {
    // In case of onVisibilityChanged fired after dispose()
    if (_timers == null) return;
    
    if (visibilityInfo.visibleFraction == 1) {
      _timers![widget.exposureKey] ??=
          Timer(widget.threshold, () => widget.onImpress(visibilityInfo));
    } else {
      if (_timers![widget.exposureKey]?.isActive == true) {
        _timers![widget.exposureKey]?.cancel();
        _timers![widget.exposureKey] = null;
      }
    }
  }
}
