import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../config/app_config.dart';

/// Professional loading indicator customized for the DFM Korba visual brand.
class DfmLoadingIndicator extends StatelessWidget {
  final double size;
  final String? message;
  final double? progress; // 0.0 to 1.0

  const DfmLoadingIndicator({
    super.key,
    this.size = 48.0,
    this.message,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SpinKitDualRing(
                color: AppConfig.primaryBlue,
                size: size,
                lineWidth: 3.5,
              ),
              SpinKitPulse(
                color: AppConfig.accentAmber.withOpacity(0.6),
                size: size * 0.5,
              ),
            ],
          ),
          if (progress != null && progress! > 0 && progress! < 1.0) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: 140,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppConfig.chassisBorder,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppConfig.accentAmber),
                  minHeight: 4,
                ),
              ),
            ),
          ],
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: const TextStyle(
                color: AppConfig.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A thin horizontal progress bar displayed at the top of the WebView while navigating.
class DfmTopProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0

  const DfmTopProgressBar({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    if (progress <= 0 || progress >= 1.0) {
      return const SizedBox.shrink();
    }

    return LinearProgressIndicator(
      value: progress,
      backgroundColor: Colors.transparent,
      valueColor: const AlwaysStoppedAnimation<Color>(AppConfig.accentAmber),
      minHeight: 2.5,
    );
  }
}
