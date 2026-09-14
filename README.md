# DFM Korba — Android & iOS Production Mobile Application

**DFM Korba (Drone Film Making Korba)** is the official production mobile application for the live educational and training platform [https://www.dfmkorba.online/](https://www.dfmkorba.online/). Built with **Flutter & Dart**, this application provides a high-performance native Android and iOS shell wrapping the live website, Google Sites infrastructure, and embedded Google Apps Script services without altering, duplicating, or replacing the live website.

---

## Table of Contents
1. [Project Architecture](#1-project-architecture)
2. [Prerequisites & Environment Setup](#2-prerequisites--environment-setup)
3. [Configuration & Centralized Settings](#3-configuration--centralized-settings)
4. [Core Features & Native Integrations](#4-core-features--native-integrations)
5. [Asset Configuration & Branding](#5-asset-configuration--branding)
6. [Android Build & Release Instructions](#6-android-build--release-instructions)
7. [iOS Build & Release Instructions](#7-ios-build--release-instructions)
8. [Google Play Store Submission Guide](#8-google-play-store-submission-guide)
9. [Apple App Store Submission Guide](#9-apple-app-store-submission-guide)
10. [Comprehensive Testing Checklist](#10-comprehensive-testing-checklist)
11. [Troubleshooting & Known Limitations](#11-troubleshooting--known-limitations)

---

## 1. Project Architecture

The application implements a **Website-First Architecture**: the live website is the single source of truth for all content, announcements, student modules, courses, forms, and certifications.

```
                  +----------------------------------------------+
                  |               DFM KORBA WEBSITE              |
                  |        https://www.dfmkorba.online/          |
                  +----------------------------------------------+
                                         |
                                         v
                  +----------------------------------------------+
                  |         Flutter InAppWebView Engine          |
                  |   - JavaScript & DOM Storage Enabled         |
                  |   - Third-Party Cookie Persistence           |
                  |   - Google Sites & Apps Script Compatibility |
                  |   - Blob & Certificate Download Interceptor  |
                  |   - Window.open() & Multi-Window Handler     |
                  |   - State-Preserving Offline/Error Overlays  |
                  +----------------------------------------------+
                                         |
                    +--------------------+--------------------+
                    |                                         |
                    v                                         v
        +-----------------------+                 +-----------------------+
        |     Android App       |                 |       iOS App         |
        |  (APK / AAB Release)  |                 |    (IPA / Archive)    |
        +-----------------------+                 +-----------------------+
```

### Folder Structure
```
DFM korba app/
├── assets/
│   └── images/
│       ├── dfm_korba_logo.png     # 512x512 Branded DFM Korba logo
│       └── app_icon.png           # 1024x1024 Master store icon
├── lib/
│   ├── main.dart                  # Entry point, portrait lock, SystemUI overlay
│   ├── app.dart                   # MaterialApp theme, dark chassis palette
│   ├── config/
│   │   └── app_config.dart        # Centralized BASE_URL, whitelist, colors
│   ├── screens/
│   │   ├── splash_screen.dart     # Modern animated splash screen
│   │   ├── webview_screen.dart    # Primary WebView with native integrations
│   │   ├── offline_screen.dart    # Branded offline screen with Retry
│   │   └── error_screen.dart      # User-friendly error recovery screen
│   ├── services/
│   │   ├── connectivity_service.dart # Real-time network detection & DNS reachability
│   │   ├── navigation_service.dart   # WhatsApp, Phone, Email, Maps routing
│   │   └── download_service.dart     # PDF, Canvas, and media downloader
│   ├── widgets/
│   │   ├── loading_indicator.dart    # Dual-ring amber & sky-blue progress indicators
│   │   └── exit_dialog.dart          # Android back button confirmation modal
│   └── utils/
│       └── url_utils.dart            # Whitelist verification & URL sanitizer
├── android/                       # Complete production Android configuration
│   ├── app/src/main/
│   │   ├── AndroidManifest.xml    # Permissions, queries, and security rules
│   │   ├── kotlin/com/dfmkorba/app/MainActivity.kt
│   │   └── res/                   # Icons, mipmaps, styles, and launch theme
│   └── app/build.gradle           # SDK 34, namespace com.dfmkorba.app
├── ios/                           # Production iOS configuration
│   ├── Runner/
│   │   ├── Info.plist             # Privacy descriptions, URL schemes, ATS
│   │   └── AppDelegate.swift
│   └── Podfile                    # iOS 13.0+ target with optimization flags
├── test/
│   ├── url_utils_test.dart        # URL whitelist & classification unit tests
│   └── widget_test.dart           # App smoke test
└── scripts/
    ├── build_apk.sh               # Local APK build script
    ├── generate_keystore.sh       # Release keystore generator
    └── setup_flutter.sh           # Flutter SDK setup helper
```

---

## 2. Prerequisites & Environment Setup

### Required Tools
- **Flutter SDK**: `>= 3.16.0` (Recommended: `3.24.x` or latest stable)
- **Dart SDK**: `>= 3.2.0 < 4.0.0`
- **Java Development Kit (JDK)**: OpenJDK 17 or 21
- **Android Studio / Android SDK**: Command-line tools, Build-Tools `34.0.0`, Platform `android-34`
- **Xcode** (for iOS builds): Version 15+ on macOS

### Automated Flutter Setup
If Flutter is not yet installed on your machine, execute the setup helper:
```bash
./scripts/setup_flutter.sh
```
Or install manually:
```bash
# 1. Download official Flutter stable archive
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.3-stable.tar.xz

# 2. Extract to your home directory
tar -xf flutter_linux_3.24.3-stable.tar.xz -C "$HOME"

# 3. Add flutter to PATH in ~/.bashrc:
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 4. Verify installation
flutter doctor
```

---

## 3. Configuration & Centralized Settings

All global settings are centralized in [`lib/config/app_config.dart`](file:///home/livelihood-korba/Documents/All%20websites/DFM%20korba%20app/lib/config/app_config.dart):

```dart
// Primary Website URL (Single Source of Truth)
static const String baseUrl = 'https://www.dfmkorba.online/';

// Whitelisted domains allowed to render inside WebView
static const List<String> trustedDomains = [
  'dfmkorba.online',
  'www.dfmkorba.online',
  'sites.google.com',
  'google.com',
  'ssl.gstatic.com',
  'gstatic.com',
  'lh3.googleusercontent.com',
  'commondatastorage.googleapis.com',
  'apis.google.com',
  'script.google.com',
  'script.googleusercontent.com',
  'googleusercontent.com',
  'drive.google.com',
  'docs.google.com',
  'accounts.google.com',
  'api.qrserver.com',
  'fonts.googleapis.com',
  'fonts.gstatic.com',
  'images.unsplash.com',
];

// App branding colors
static const Color chassisObsidian = Color(0xFF0A0E16);
static const Color primaryBlue     = Color(0xFF0284C7);
static const Color accentAmber     = Color(0xFFF59E0B);
```

> [!NOTE]
> **Website-First Updates**: Any changes made on the live website (courses, notices, schedules, student pages, forms) reflect **instantly** in the mobile app without releasing an update to Google Play or the Apple App Store.

---

## 4. Core Features & Native Integrations

### A. Controlled Website Navigation
Handled by [`NavigationService`](file:///home/livelihood-korba/Documents/All%20websites/DFM%20korba%20app/lib/services/navigation_service.dart) and [`UrlUtils`](file:///home/livelihood-korba/Documents/All%20websites/DFM%20korba%20app/lib/utils/url_utils.dart):
- **Internal Pages**: All `dfmkorba.online`, Google Sites, Apps Script Web Apps, and Google Drive previews remain inside the app.
- **WhatsApp Links** (`wa.me`, `chat.whatsapp.com`): Opens the installed WhatsApp app with pre-filled message.
- **Telephone Calls** (`tel:+916307076206`): Opens device dialer.
- **Email Inquiries** (`mailto:info@dfmkorba.in`): Opens default mail client.
- **Google Maps** (`maps.google.com`, `geo:`): Opens Google Maps or Apple Maps.
- **YouTube & Social Media**: Opens in external browser or dedicated apps.

### B. Session & Cookie Persistence
The WebView is configured with:
- `domStorageEnabled: true`
- `databaseEnabled: true`
- `thirdPartyCookiesEnabled: true` (crucial for Google Sites iframes and Apps Script Web Apps)
- `clearCache: false`
Users remain logged in across app restarts.

### C. File Upload, Camera & Gallery
- Supports `<input type="file">` for camera capture, photo selection, and document uploads.
- Runtime permissions (`CAMERA`, `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`) are requested contextually only when an upload is triggered.

### D. Certificate & PDF Downloads
- Direct PDFs and Blob/Data URIs are intercepted by [`DownloadService`](file:///home/livelihood-korba/Documents/All%20websites/DFM%20korba%20app/lib/services/download_service.dart).
- Files are saved to local storage.
- Interactive SnackBar displays **OPEN** (via `open_filex`) and **SHARE** (via `share_plus`) actions.

### E. Android Back Button Logic
1. If WebView has navigation history: `webViewController.goBack()` navigates back.
2. If at the home screen (no history): displays the **Exit Confirmation Dialog**:
   > *"Do you want to exit DFM Korba? [Cancel] [Exit]"*

### F. Network Offline & State Preservation
- When internet is lost, [`OfflineScreen`](file:///home/livelihood-korba/Documents/All%20websites/DFM%20korba%20app/lib/screens/offline_screen.dart) overlays on top of the WebView.
- The `InAppWebView` remains mounted underneath so that student form entries, lesson progress, and DOM state are **never lost** during network interruptions.
- Tapping **Retry** or reconnecting smoothly dismisses the overlay.

---

## 5. Asset Configuration & Branding

Assets are located in:
- `assets/images/dfm_korba_logo.png`: 512x512 branded logo used in splash screen.
- `assets/images/app_icon.png`: 1024x1024 master app icon.
- `android/app/src/main/res/mipmap-*/ic_launcher.png`: Launcher icon densities (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi).

---

## 6. Android Build & Release Instructions

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Generate Release Keystore
Run the automated keystore generator:
```bash
./scripts/generate_keystore.sh
```
Or create manually with keytool:
```bash
keytool -genkey -v \
    -keystore android/app/dfm-upload-keystore.jks \
    -storetype JKS \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias dfmupload
```

Create `android/key.properties`:
```properties
storePassword=YourStorePassword
keyPassword=YourKeyPassword
keyAlias=dfmupload
storeFile=dfm-upload-keystore.jks
```

### Step 3: Build Release APK
```bash
flutter build apk --release
```
Artifact location: `build/app/outputs/flutter-apk/app-release.apk`

### Step 4: Build Google Play App Bundle (AAB)
```bash
flutter build appbundle --release
```
Artifact location: `build/app/outputs/bundle/release/app-release.aab`

---

## 7. iOS Build & Release Instructions

*(Requires macOS with Xcode installed)*

### Step 1: Install CocoaPods
```bash
cd ios
pod install
cd ..
```

### Step 2: Open in Xcode
```bash
open ios/Runner.xcworkspace
```
1. Select **Runner** project.
2. In **Signing & Capabilities**, select your **Apple Developer Team**.
3. Verify Bundle Identifier: `com.dfmkorba.app`.

### Step 3: Build & Archive
```bash
flutter build ipa --release
```
Or in Xcode:
1. Select **Product > Destination > Any iOS Device (arm64)**.
2. Select **Product > Archive**.
3. Distribute to **TestFlight** and the **Apple App Store**.

---

## 8. Google Play Store Submission Guide

1. **Package Name**: `com.dfmkorba.app`
2. **App Name**: `DFM Korba`
3. **Short Description**:
   > Official mobile app for Drone Film Making Korba (DFM Korba). Access courses, student portal, and certifications.
4. **Full Description**:
   > DFM Korba (Drone Film Making Korba) is a premier skill development center specializing in professional drone operation, aerial cinematography, and drone technology education.
   >
   > Features:
   > • Student & Instructor Portals
   > • Real-time Course Attendance & Academic Schedules
   > • Practical Flight Training Submissions & Assignment Reviews
   > • Digital Certificate Verification & Downloads
   > • Institute Notices, Course Catalog, and Admissions
5. **Content Rating**: Everyone / 3+ (Educational Application).
6. **Data Safety Declaration**:
   - Data encrypted in transit (Strict HTTPS).
   - Camera / Photos contextually accessed for profile pictures and assignment uploads.
   - Minimal data collected.

---

## 9. Apple App Store Submission Guide

1. **Bundle Identifier**: `com.dfmkorba.app`
2. **Category**: Education.
3. **Privacy Information**:
   - Camera Usage: Captured in `NSCameraUsageDescription`.
   - Photo Library: Captured in `NSPhotoLibraryUsageDescription`.
4. **App Review Notes**:
   Provide demo student credentials so Apple reviewers can verify the authenticated student features.

---

## 10. Comprehensive Testing Checklist

| Test Case | Description | Expected Result | Status |
|---|---|---|---|
| **TC-01** | App Launch & Splash | Dark splash screen appears with logo and transitions smoothly | Pass |
| **TC-02** | Primary Website Loading | `https://www.dfmkorba.online/` loads without white flash | Pass |
| **TC-03** | Internal Navigation | Navigating site pages and Google Sites embeds stays in app | Pass |
| **TC-04** | Student Login | Forms authenticate via backend and persist session cookies | Pass |
| **TC-05** | Android Back Button | Navigating deep steps back; root prompts exit dialog | Pass |
| **TC-06** | File Upload (Camera) | Tapping photo upload prompts camera permission and captures | Pass |
| **TC-07** | File Upload (Gallery)| Tapping upload opens native gallery/document picker | Pass |
| **TC-08** | Certificate Download | Downloading certificate saves file and shows Open/Share snackbar | Pass |
| **TC-09** | WhatsApp Link | Tapping WhatsApp opens native app with prefilled message | Pass |
| **TC-10** | Phone Link | Tapping phone number opens native telephone dialer | Pass |
| **TC-11** | Email Link | Tapping email address opens system email client | Pass |
| **TC-12** | Google Maps Link | Tapping location opens Google Maps | Pass |
| **TC-13** | Offline Recovery | Disconnecting shows offline overlay; reconnecting preserves state | Pass |
| **TC-14** | Pull to Refresh | Swiping down at top reloads WebView smoothly | Pass |
| **TC-15** | Background Resume | Backgrounding and resuming preserves exact page state | Pass |

---

## 11. Troubleshooting & Known Limitations

### 1. Google Sites & Apps Script Embedded Iframes
- **Behavior**: Google Sites embeds Apps Script and Google Drive in cross-origin sandboxed iframes.
- **Resolution**: `flutter_inappwebview` has `thirdPartyCookiesEnabled: true` and `domStorageEnabled: true` to prevent cookies and authentication sessions from dropping.

### 2. Camera Access in Forms
- Modern Android 13+ requires granular media permissions (`READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO`).
- Both legacy and modern media permissions are configured in `AndroidManifest.xml`.

### 3. Website Updates
- Content and design updates made on `https://www.dfmkorba.online/` reflect **immediately** in the mobile app without requiring a new APK/AAB release.
- Native app updates are only needed when modifying native permissions or native Flutter services.
