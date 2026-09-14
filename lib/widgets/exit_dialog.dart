import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// Exit confirmation dialog conforming to Section 7 requirements:
/// Prompt: "Do you want to exit the app?"
/// Buttons: "Cancel", "Exit"
class ExitConfirmationDialog extends StatelessWidget {
  const ExitConfirmationDialog({super.key});

  /// Static helper to display the dialog and return user decision.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ExitConfirmationDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppConfig.chassisSlate,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppConfig.chassisBorder, width: 1),
      ),
      elevation: 12,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppConfig.accentAmber.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.Border.all(
                      color: AppConfig.accentAmber.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.exit_to_app_rounded,
                    color: AppConfig.accentAmber,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  AppConfig.appName,
                  style: TextStyle(
                    color: AppConfig.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Do you want to exit the app?',
              style: TextStyle(
                color: AppConfig.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'You are at the home screen of DFM Korba.',
              style: TextStyle(
                color: AppConfig.textMuted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConfig.textSecondary,
                    side: const BorderSide(color: AppConfig.chassisBorderBright),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text(
                    'Exit',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
