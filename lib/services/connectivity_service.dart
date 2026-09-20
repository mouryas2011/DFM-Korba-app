import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service for monitoring real-time network connectivity changes
/// with true DNS reachability verification to prevent false offline flags.
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  // Optimistic initial state: Assume connected so WebView starts loading immediately
  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier<bool>(true);
  bool get isConnected => isConnectedNotifier.value;

  /// Initializes the real-time connectivity listener and validates connection.
  Future<void> initialize() async {
    try {
      // Start listening to system connectivity changes
      _subscription = _connectivity.onConnectivityChanged.listen((results) {
        _handleConnectivityResults(results);
      });

      // Initial check on startup
      final initialResults = await _connectivity.checkConnectivity();
      await _handleConnectivityResults(initialResults);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ConnectivityService] Initialization error: $e');
      }
      // Fail open so users are never falsely blocked on startup errors
      isConnectedNotifier.value = true;
    }
  }

  /// Processes connectivity results with dual verification:
  /// 1. If an active interface is reported (WiFi/Cellular/VPN/Ethernet), mark online.
  /// 2. If 'none' is reported, verify via true DNS socket before marking offline.
  Future<void> _handleConnectivityResults(List<ConnectivityResult> results) async {
    if (results.isEmpty) {
      isConnectedNotifier.value = true;
      return;
    }

    final hasActiveInterface = results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.vpn ||
        result == ConnectivityResult.other);

    if (hasActiveInterface) {
      isConnectedNotifier.value = true;
      return;
    }

    // Link layer reported 'none'. On Android cold start, this is often a false negative.
    // Verify true reachability via DNS before accepting an offline state.
    final hasTrueInternet = await checkInternetReachability();
    isConnectedNotifier.value = hasTrueInternet;
  }

  /// Actively tests true internet reachability via DNS socket resolution.
  Future<bool> checkInternetReachability() async {
    try {
      final results = await InternetAddress.lookup('dfmkorba.online')
          .timeout(const Duration(seconds: 3));
      if (results.isNotEmpty && results[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {
      // Fallback to Google public DNS host
      try {
        final fallback = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 3));
        if (fallback.isNotEmpty && fallback[0].rawAddress.isNotEmpty) {
          return true;
        }
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  /// Forces an active check and updates the notifier value.
  Future<bool> refreshStatus() async {
    final reachable = await checkInternetReachability();
    isConnectedNotifier.value = reachable;
    return reachable;
  }

  /// Disposes the connectivity stream subscription.
  void dispose() {
    _subscription?.cancel();
    isConnectedNotifier.dispose();
  }
}
