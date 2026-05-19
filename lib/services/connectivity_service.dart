import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService() : _connectivity = Connectivity();

  final Connectivity _connectivity;
  final _online = StreamController<bool>.broadcast();
  bool _lastOnline = true;

  Stream<bool> get onStatusChange => _online.stream;
  bool get isConnected => _lastOnline;

  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    _lastOnline = _hasConnection(result);
    return _lastOnline;
  }

  void startListening() {
    _connectivity.onConnectivityChanged.listen((result) {
      final online = _hasConnection(result);
      if (online != _lastOnline) {
        _lastOnline = online;
        _online.add(online);
      }
    });
  }

  bool _hasConnection(List<ConnectivityResult> result) {
    return result.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet,
    );
  }

  void dispose() => _online.close();
}
