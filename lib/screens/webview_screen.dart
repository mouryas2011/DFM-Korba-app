import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/app_config.dart';
import '../services/connectivity_service.dart';
import '../services/download_service.dart';
import '../services/navigation_service.dart';
import '../utils/url_utils.dart';
import '../widgets/exit_dialog.dart';
import '../widgets/loading_indicator.dart';
import 'error_screen.dart';
import 'offline_screen.dart';

/// Primary production WebView container hosting https://www.dfmkorba.online/
class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> with WidgetsBindingObserver {
  InAppWebViewController? _webViewController;
  PullToRefreshController? _pullToRefreshController;

  double _loadingProgress = 0.0;
  bool _isInitialLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _wasOffline = false;

  final ConnectivityService _connectivityService = ConnectivityService();
  late final InAppWebViewSettings _webViewSettings;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initWebViewSettings();
    _initPullToRefresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _webViewController != null) {
      // Avoid reloading on app resume; preserve exact state
      if (kDebugMode) {
        debugPrint('[WebView] App resumed, preserving state.');
      }
    }
  }

  void _initWebViewSettings() {
    _webViewSettings = InAppWebViewSettings(
      // JavaScript & Storage Configurations
      javaScriptEnabled: true,
      domStorageEnabled: true,
      databaseEnabled: true,
      cacheEnabled: true,
      clearCache: false, // Maintain session / token persistence across launches

      // Cookie Configurations (Critical for Google Sites and Google Apps Script embeds)
      thirdPartyCookiesEnabled: true,

      // File & Media Handling
      allowFileAccess: true,
      allowContentAccess: true,
      allowsInlineMediaPlayback: true,
      mediaPlaybackRequiresUserGesture: false,

      // Window & Navigation Handling
      supportMultipleWindows: true,
      javaScriptCanOpenWindowsAutomatically: true,
      useShouldOverrideUrlLoading: true,
      useOnDownloadStart: true,

      // Security: Strict HTTPS Enforced
      mixedContentMode: MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
      safeBrowsingEnabled: true,

      // Visual & Rendering
      transparentBackground: false,
      useHybridComposition: true,
      disallowOverScroll: false,
    );
  }

  void _initPullToRefresh() {
    _pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(
              color: AppConfig.accentAmber,
              backgroundColor: AppConfig.chassisSlate,
            ),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                _webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                _webViewController?.loadUrl(
                  urlRequest: URLRequest(url: await _webViewController?.getUrl()),
                );
              }
            },
          );
  }

  /// Handles Android system back button navigation.
  /// If WebView has navigation history, go back.
  /// If at root, prompt exit confirmation dialog.
  Future<void> _handlePopScope(bool didPop, dynamic result) async {
    if (didPop) return;

    if (_webViewController != null && await _webViewController!.canGoBack()) {
      await _webViewController!.goBack();
      return;
    }

    if (!mounted) return;
    final shouldExit = await ExitConfirmationDialog.show(context);
    if (shouldExit) {
      SystemNavigator.pop();
    }
  }

  /// Reloads the WebView to recover from an error or connection return.
  void _retryLoading() {
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _isInitialLoading = true;
    });
    _webViewController?.reload();
  }

  /// Navigates fresh to the primary DFM Korba website URL.
  void _reloadEntireApp() {
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _isInitialLoading = true;
    });
    _webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri(AppConfig.baseUrl)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handlePopScope,
      child: Scaffold(
        backgroundColor: AppConfig.chassisObsidian,
        body: ValueListenableBuilder<bool>(
          valueListenable: _connectivityService.isConnectedNotifier,
          builder: (context, isConnected, child) {
            // Automatically reload if we were previously offline and connection returned
            if (isConnected && _wasOffline) {
              _wasOffline = false;
              if (_hasError) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _retryLoading();
                });
              }
            } else if (!isConnected) {
              _wasOffline = true;
            }

            return SafeArea(
              child: Stack(
                children: [
                  // 1. Primary WebView - ALWAYS kept mounted to preserve DOM and form state
                  InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri(AppConfig.baseUrl),
                    ),
                    initialSettings: _webViewSettings,
                    pullToRefreshController: _pullToRefreshController,
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                    },
                    onLoadStart: (controller, url) {
                      if (kDebugMode) {
                        debugPrint('[WebView] onLoadStart: ${UrlUtils.sanitizeUrlForLogging(url?.toString() ?? '')}');
                      }
                      setState(() {
                        _hasError = false;
                        _loadingProgress = 0.1;
                      });
                    },
                    onLoadStop: (controller, url) async {
                      if (kDebugMode) {
                        debugPrint('[WebView] onLoadStop: ${UrlUtils.sanitizeUrlForLogging(url?.toString() ?? '')}');
                      }
                      _pullToRefreshController?.endRefreshing();
                      setState(() {
                        _isInitialLoading = false;
                        _loadingProgress = 1.0;
                      });
                    },
                    onProgressChanged: (controller, progress) {
                      if (progress == 100) {
                        _pullToRefreshController?.endRefreshing();
                      }
                      setState(() {
                        _loadingProgress = progress / 100;
                        if (progress > 85) {
                          _isInitialLoading = false;
                        }
                      });
                    },
                    onReceivedError: (controller, request, error) {
                      _pullToRefreshController?.endRefreshing();
                      // Only handle fatal connectivity / host lookup / timeout failures
                      if (error.type == WebResourceErrorType.CANNOT_CONNECT_TO_HOST ||
                          error.type == WebResourceErrorType.HOST_LOOKUP ||
                          error.type == WebResourceErrorType.TIMEOUT) {
                        setState(() {
                          _hasError = true;
                          _errorMessage =
                              'Please check your internet connection and try again.';
                          _isInitialLoading = false;
                        });
                      }
                    },
                    onReceivedHttpError: (controller, request, errorResponse) {
                      if (request.isForMainFrame ?? false) {
                        if ((errorResponse.statusCode ?? 0) >= 500) {
                          setState(() {
                            _hasError = true;
                            _errorMessage =
                                'DFM Korba server temporarily unavailable (${errorResponse.statusCode}). Please try again shortly.';
                          });
                        }
                      }
                    },
                    shouldOverrideUrlLoading: (controller, navigationAction) async {
                      final uri = navigationAction.request.url?.uriValue;
                      if (uri == null) {
                        return NavigationActionPolicy.ALLOW;
                      }

                      // Intercept external schemes (WhatsApp, phone, mailto, maps, YouTube, external sites)
                      final handled =
                          await NavigationService.handleNavigation(context, uri);
                      if (handled) {
                        return NavigationActionPolicy.CANCEL;
                      }

                      // If a standalone PDF file is opened directly, download and open natively
                      if (UrlUtils.isPdf(uri) && !uri.host.contains('drive.google.com')) {
                        await DownloadService.handleDownload(
                          context: context,
                          url: uri.toString(),
                        );
                        return NavigationActionPolicy.CANCEL;
                      }

                      return NavigationActionPolicy.ALLOW;
                    },
                    onCreateWindow: (controller, createWindowAction) async {
                      // Support window.open() & target="_blank" (e.g. popups, Google Auth)
                      final uri = createWindowAction.request.url?.uriValue;
                      if (uri != null) {
                        final handled =
                            await NavigationService.handleNavigation(context, uri);
                        if (!handled) {
                          controller.loadUrl(
                            urlRequest: URLRequest(url: WebUri.uri(uri)),
                          );
                        }
                      }
                      return true;
                    },
                    onDownloadStartRequest: (controller, downloadStartRequest) async {
                      // Support student downloads (PDFs, certificates, course material)
                      await DownloadService.handleDownload(
                        context: context,
                        url: downloadStartRequest.url.toString(),
                        suggestedFilename: downloadStartRequest.suggestedFilename,
                        mimeType: downloadStartRequest.mimeType,
                      );
                    },
                    onPermissionRequest: (controller, permissionRequest) async {
                      // Contextual runtime permission verification for camera / microphone
                      for (final resource in permissionRequest.resources) {
                        if (resource == PermissionResourceType.CAMERA) {
                          final status = await Permission.camera.request();
                          if (!status.isGranted) {
                            return PermissionResponse(
                              resources: permissionRequest.resources,
                              action: PermissionResponseAction.DENY,
                            );
                          }
                        } else if (resource == PermissionResourceType.MICROPHONE) {
                          final status = await Permission.microphone.request();
                          if (!status.isGranted) {
                            return PermissionResponse(
                              resources: permissionRequest.resources,
                              action: PermissionResponseAction.DENY,
                            );
                          }
                        }
                      }
                      return PermissionResponse(
                        resources: permissionRequest.resources,
                        action: PermissionResponseAction.GRANT,
                      );
                    },
                  ),

                  // 2. Top Slim Progress Bar
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: DfmTopProgressBar(progress: _loadingProgress),
                  ),

                  // 3. Initial Handshake Loading Indicator
                  if (_isInitialLoading && !_hasError && isConnected)
                    Container(
                      color: AppConfig.chassisObsidian,
                      child: const DfmLoadingIndicator(
                        message: 'Connecting to DFM Korba...',
                      ),
                    ),

                  // 4. Fatal Error Overlay (Retry / Reload)
                  if (_hasError && isConnected)
                    Positioned.fill(
                      child: ErrorScreen(
                        errorMessage: _errorMessage,
                        onRetry: _retryLoading,
                        onReload: _reloadEntireApp,
                      ),
                    ),

                  // 5. Offline Screen Overlay (Preserves WebView underneath)
                  if (!isConnected)
                    Positioned.fill(
                      child: OfflineScreen(
                        onRetry: () async {
                          final reachable =
                              await _connectivityService.checkInternetReachability();
                          if (reachable) {
                            _retryLoading();
                          }
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
