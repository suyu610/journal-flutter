import 'package:flutter/material.dart';

import 'navigation_history_observer.dart';

abstract class PageState<T extends StatefulWidget> extends State<T>
    with PageStateMixin {
  static final List<BuildContext> _contextList = [];

  @override
  void initState() {
    super.initState();
    onCreate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addToContextList();
    });
  }

  @override
  void dispose() {
    onDestroy();
    _removeFromContextList();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _addToContextList() {
    if (!mounted) return;
    if (!_contextList.contains(context)) {
      _contextList.add(context);
    }
  }

  void _removeFromContextList() {
    if (_contextList.isEmpty) return;
    _contextList.removeWhere((element) => element == context);
  }
}

mixin PageStateMixin<T extends StatefulWidget> on State<T> {
  Route? _route;

  @override
  void didChangeDependencies() {
    _route ??= ModalRoute.of(context);
    if (_route != null) {
      RouteHistoryObserver.addResumeCallback(_route!, onResume);
      RouteHistoryObserver.addPauseCallback(_route!, onPause);
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _route ??= ModalRoute.of(context);
    if (_route != null) {
      RouteHistoryObserver.removeResumeCallback(_route!, onResume);
      RouteHistoryObserver.removePauseCallback(_route!, onPause);
    }
    super.dispose();
  }

  void onCreate() {}

  void onResume() {}

  void onPause() {}

  void onDestroy() {}
}

class RouteHistoryObserver with WidgetsBindingObserver {
  static final Map<Route, Set<VoidCallback>> _resumeCallbacks = {};
  static final Map<Route, Set<VoidCallback>> _pauseCallbacks = {};
  static bool _initialized = false;
  static Route? _currTopRoute;

  static Route<dynamic>? get topRoute => _currTopRoute;

  static void init() {
    if (_initialized) return;
    _initialized = true;
    NavigationHistoryObserver()
        .historyChangeStream
        .listen(_appRouteHistoryChange);
    WidgetsBinding.instance.addObserver(RouteHistoryObserver());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _appResume();
    } else if (state == AppLifecycleState.paused) {
      _appPause();
    }
  }

  static void _appRouteHistoryChange(dynamic historyChange) {
    if (NavigationHistoryObserver().history.isEmpty) return;
    var topRoute = NavigationHistoryObserver().top;
    if (historyChange.action == NavigationStackAction.push) {
      var preRoute = (historyChange as HistoryChange).oldRoute;
      var pauseCallbackList = _pauseCallbacks[preRoute];
      if (pauseCallbackList != null) {
        for (var callback in pauseCallbackList) {
          callback.call();
        }
      }
    } else if (historyChange.action == NavigationStackAction.pop) {
      var pauseCallbackList = _pauseCallbacks[_currTopRoute];
      if (pauseCallbackList != null) {
        for (var callback in pauseCallbackList) {
          callback.call();
        }
      }
    }

    if (topRoute != _currTopRoute) {
      _currTopRoute = topRoute;
      var resumeCallbackList = _resumeCallbacks[topRoute];
      if (resumeCallbackList == null) return;
      for (var callback in resumeCallbackList) {
        callback.call();
      }
    }
  }

  static void addResumeCallback(Route route, VoidCallback callback) {
    var callbackList = _resumeCallbacks[route];
    if (callbackList == null) {
      callbackList = {};
      _resumeCallbacks[route] = callbackList;
    }
    if (callbackList.add(callback) && _currTopRoute == route) {
      callback.call();
    }
  }

  static void removeResumeCallback(Route route, VoidCallback callback) {
    var callbackList = _resumeCallbacks[route];
    if (callbackList == null) return;
    callbackList.remove(callback);
  }

  static void addPauseCallback(Route route, VoidCallback callback) {
    var callbackList = _pauseCallbacks[route];
    if (callbackList == null) {
      callbackList = {};
      _pauseCallbacks[route] = callbackList;
    }
    callbackList.add(callback);
  }

  static void removePauseCallback(Route route, VoidCallback callback) {
    var callbackList = _pauseCallbacks[route];
    if (callbackList == null) return;
    callbackList.remove(callback);
  }

  static void _appResume() {
    if (_currTopRoute == null) return;
    var callbackList = _resumeCallbacks[_currTopRoute];
    if (callbackList == null) return;
    for (var callback in callbackList) {
      callback.call();
    }
  }

  static void _appPause() {
    if (_currTopRoute == null) return;
    var pauseCallbackList = _pauseCallbacks[_currTopRoute];
    if (pauseCallbackList == null) return;
    for (var callback in pauseCallbackList) {
      callback.call();
    }
  }
}
