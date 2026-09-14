import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service for monitoring real-time network connectivity changes.
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier<bool>(true);
  bool get isConnected => isConnectedNotifier.value;

  /// Initializes the real-time connectivity listener.
  Future<void> initialize() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);

      _subscription = _connectivity.onConnectivityChanged.listen((results) {
        _updateConnectionStatus(results);
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ConnectivityService] Init error: $e');
      }
    }
  }

  /// Updates the notifier and verifies actual DNS reachability.
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final hasLocalInterface = results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);

    if (!hasLocalInterface) {
      isConnectedNotifier.value = false;
    } else {
      // Local interface is active; verify actual internet reachability asynchronously
      checkInternetReachability().then((hasRealInternet) {
        isConnectedNotifier.value = hasRealInternet;
      });
    }
  }

  /// Actively tests whether the device can resolve and reach public DNS.
  Future<bool> checkInternetReachability() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Disposes the connectivity stream subscription.
  void dispose() {
    _subscription?.cancel();
    isConnectedNotifier.dispose();
  }
}
