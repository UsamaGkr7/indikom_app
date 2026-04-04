import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  final Connectivity _connectivity = Connectivity();

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Stream<ConnectivityResult> get onStatusChange =>
      _connectivity.onConnectivityChanged.map((results) {
        if (results.isNotEmpty) return results.first;
        return ConnectivityResult.none;
      });
}
