import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// Professional offline screen displayed when the device loses network connectivity.
/// Displays:
///   "NO INTERNET CONNECTION"
///   "Please check your internet connection and try again."
///   Button: "Retry"
class OfflineScreen extends StatefulWidget {
  final Future<void> Function() onRetry;

  const OfflineScreen({
    super.key,
    required this.onRetry,
  });

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  bool _isRetrying = false;

  Future<void> _handleRetry() async {
    if (_isRetrying) return;

    setState(() => _isRetrying = true);
    try {
      await widget.onRetry();
    } finally {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.chassisObsidian,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Offline Radar Indicator
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppConfig.chassisSlate,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppConfig.accentAmber.withOpacity(0.35),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppConfig.accentAmber.withOpacity(0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.wifi_off_rounded,
                      size: 46,
                      color: AppConfig.accentAmber,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Title required by Prompt
                const Text(
                  'NO INTERNET CONNECTION',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppConfig.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),

                const SizedBox(height: 12),

                // Description required by Prompt
                const Text(
                  'Please check your internet connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppConfig.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 36),

                // Retry Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isRetrying ? null : _handleRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.primaryBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppConfig.chassisBorder,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: _isRetrying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Retry',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
