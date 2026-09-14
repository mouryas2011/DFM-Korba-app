import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// User-friendly error screen displayed when a network timeout, DNS failure,
/// or server-side error prevents the Web App from rendering.
/// Never exposes raw technical stack traces to students.
class ErrorScreen extends StatefulWidget {
  final String? errorTitle;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback? onReload;

  const ErrorScreen({
    super.key,
    this.errorTitle,
    this.errorMessage,
    required this.onRetry,
    this.onReload,
  });

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  bool _isLoading = false;

  void _triggerRetry() {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    widget.onRetry();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _triggerReload() {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    widget.onReload?.call();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isLoading = false);
    });
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
                // Error Emblem
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppConfig.chassisSlate,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppConfig.accentRed.withOpacity(0.35),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppConfig.accentRed.withOpacity(0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.cloud_off_rounded,
                      size: 44,
                      color: AppConfig.accentRed,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  widget.errorTitle ?? 'Unable to Connect to DFM Korba',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppConfig.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  widget.errorMessage ??
                      'The DFM Korba application server is taking too long to respond. Please check your network and try again.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                    onPressed: _isLoading ? null : _triggerRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
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

                if (widget.onReload != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _triggerReload,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConfig.textPrimary,
                        side: const BorderSide(color: AppConfig.chassisBorderBright),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restart_alt_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Reload Application',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
