import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../config/app_config.dart';

/// Service responsible for managing downloads, saving PDFs, certificates,
/// and media to local storage, and providing open/share capabilities.
class DownloadService {
  DownloadService._();

  /// Handles incoming download requests originating from the WebView.
  static Future<void> handleDownload({
    required BuildContext context,
    required String url,
    String? suggestedFilename,
    String? mimeType,
  }) async {
    try {
      _showDownloadStartedSnackBar(context);

      File? savedFile;
      if (url.startsWith('data:')) {
        savedFile = await _saveDataUri(url, suggestedFilename);
      } else {
        savedFile = await _downloadHttpFile(url, suggestedFilename);
      }

      if (savedFile != null && await savedFile.exists()) {
        _showDownloadCompleteSnackBar(context, savedFile);
      } else {
        _showErrorSnackBar(context, 'Failed to save downloaded file.');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[DownloadService] Error: $e');
      _showErrorSnackBar(context, 'Download encountered an issue.');
    }
  }

  /// Saves a base64 Data URI to local disk.
  static Future<File?> _saveDataUri(String dataUri, String? suggestedFilename) async {
    try {
      final commaIndex = dataUri.indexOf(',');
      if (commaIndex == -1) return null;

      final metadata = dataUri.substring(0, commaIndex);
      final base64Data = dataUri.substring(commaIndex + 1);
      final bytes = base64Decode(base64Data);

      String extension = 'bin';
      if (metadata.contains('image/png')) {
        extension = 'png';
      } else if (metadata.contains('image/jpeg')) {
        extension = 'jpg';
      } else if (metadata.contains('application/pdf')) {
        extension = 'pdf';
      }

      final filename = suggestedFilename ??
          'dfm_certificate_${DateTime.now().millisecondsSinceEpoch}.$extension';
      return await _writeBytesToStorage(bytes, filename);
    } catch (e) {
      if (kDebugMode) debugPrint('[DownloadService] Data URI error: $e');
      return null;
    }
  }

  /// Downloads a direct HTTP/HTTPS file.
  static Future<File?> _downloadHttpFile(String url, String? suggestedFilename) async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) return null;

      final filename = suggestedFilename ??
          url.split('/').last.split('?').first;
      final safeFilename = filename.isNotEmpty ? filename : 'download_${DateTime.now().millisecondsSinceEpoch}';

      final dir = await _getStorageDirectory();
      final file = File('${dir.path}/$safeFilename');
      final sink = file.openWrite();

      await response.pipe(sink);
      await sink.flush();
      await sink.close();

      return file;
    } catch (e) {
      if (kDebugMode) debugPrint('[DownloadService] HTTP download error: $e');
      return null;
    }
  }

  /// Writes raw bytes to device documents directory.
  static Future<File> _writeBytesToStorage(List<int> bytes, String filename) async {
    final dir = await _getStorageDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// Resolves the preferred directory for saving student files.
  static Future<Directory> _getStorageDirectory() async {
    if (Platform.isAndroid) {
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) return externalDir;
    }
    return await getApplicationDocumentsDirectory();
  }

  static void _showDownloadStartedSnackBar(BuildContext context) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppConfig.accentAmber),
              ),
            ),
            SizedBox(width: 12),
            Text('Downloading file...'),
          ],
        ),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void _showDownloadCompleteSnackBar(BuildContext context, File file) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppConfig.chassisSlate,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppConfig.successGreen, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Downloaded: ${file.path.split('/').last}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppConfig.textPrimary),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'OPEN',
          textColor: AppConfig.accentAmber,
          onPressed: () => OpenFilex.open(file.path),
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConfig.accentRed,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Allows sharing a downloaded file via system share sheet.
  static Future<void> shareFile(String filePath, {String? text}) async {
    await Share.shareXFiles([XFile(filePath)], text: text);
  }
}
