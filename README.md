# DFM Korba — Android & iOS Production Mobile Application

**DFM Korba (Drone Film Making Korba)** is the official production mobile application wrapper for the DFM Korba educational and training web platform. Built with **Flutter & Dart**, this application provides a high-performance native Android and iOS shell wrapping the live Google Apps Script cloud engine without altering or replacing the existing backend.

---

## Table of Contents
1. [Project Architecture](#1-project-architecture)
2. [Prerequisites & Environment Setup](#2-prerequisites--environment-setup)
3. [Configuration & Centralized Settings](#3-configuration--centralized-settings)
4. [Core Features & Native Integrations](#4-core-features--native-integrations)
5. [Asset Configuration](#5-asset-configuration)
6. [Android Build & Release Instructions](#6-android-build--release-instructions)
7. [iOS Build & Release Instructions](#7-ios-build--release-instructions)
8. [Google Play Store Submission Guide](#8-google-play-store-submission-guide)
9. [Apple App Store Submission Guide](#9-apple-app-store-submission-guide)
10. [Comprehensive Testing Checklist](#10-comprehensive-testing-checklist)
11. [Troubleshooting & Known Limitations](#11-troubleshooting--known-limitations)

---

## 1. Project Architecture

The architecture maintains the live Google Apps Script web application as the single source of truth while providing native mobile capabilities:

```
                  +----------------------------------------------+
                  |              DFM Korba Mobile App            |
                  |                (Flutter & Dart)              |
                  +----------------------------------------------+
                                         |
                   +---------------------+---------------------+
                   |                                           |
                   v                                           v
       +-----------------------+                   +-----------------------+
       |   Native Android      |                   |      Native iOS       |
       |  (Kotlin / Gradle)    |                   |   (Swift / CocoaPods) |
       +-----------------------+                   +-----------------------+
                   |                                           |
                   +---------------------+---------------------+
                                         |
                                         v
                  +----------------------------------------------+
                  |          Production InAppWebView             |
                  |   - JavaScript & DOM Storage Enabled         |
                  |   - Third-Party Cookie Persistence           |
                  |   - File Chooser (Camera / Gallery / Docs)   |
                  |   - Blob & Certificate Download Interceptor  |
                  |   - Window.open() & Multi-Window Handler     |
                  +----------------------------------------------+
                                         |
                                         v
                  +----------------------------------------------+
                  |       Live Google Apps Script Web App        |
                  |     (Sandboxed Script UserCodeAppPanel)      |
                  +----------------------------------------------+
```

### Folder Structure
```
DFM korba app/
├── assets/
│   ├── images/
│   │   ├── dfm_korba_logo.png     # 512x512 Branded DFM Korba logo
│   │   └── app_icon.png           # 1024x1024 Master store icon
│   └── icons/
├── lib/
│   ├── main.dart                  # Entry point, orientations, and SystemUI overlay
│   ├── app.dart                   # MaterialApp theme, dark chassis palette
│   ├── config/
│   │   └── app_config.dart        # Centralized Web App URL, whitelist, colors
│   ├── screens/
│   │   ├── splash_screen.dart     # Native-style animated splash screen
│   │   ├── webview_screen.dart    # Primary WebView with full native hooks
│   │   ├── no_internet_screen.dart# Branded offline screen with retry
│   │   └── error_screen.dart      # User-friendly error recovery screen
│   ├── services/
│   │   ├── connectivity_service.dart # Real-time network detection (connectivity_plus)
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
    ├── generate_keystore.sh       # Automated release keystore generation
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

### Installing Flutter
If Flutter is not yet installed on your Linux machine, execute the automated helper:
```bash
./scripts/setup_flutter.sh
```
Or download manually:
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
// Primary Google Apps Script Web App URL
static const String webAppUrl =
    'https://script.google.com/macros/s/AKfycbxqbAmKxvfbTnv313FFoSafospHlNpbx0oY9J9gCPypU3srpSILcYJgGUyD29S1wS1h/exec';

// Whitelisted domains allowed to render inside WebView
static const List<String> trustedDomains = [
  'script.google.com',
  'script.googleusercontent.com',
  'googleusercontent.com',
  'drive.google.com',
  'docs.google.com',
  'accounts.google.com',
  'lh3.googleusercontent.com',
  'commondatastorage.googleapis.com',
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
> **Updating the Web App URL**: If you deploy a new version of your Google Apps Script Web App, change the URL **only once** in `lib/config/app_config.dart`. Do not hardcode the URL anywhere else.

---

## 4. Core Features & Native Integrations

### A. Intelligent Navigation & Deep Links
Handled by [`NavigationService`](file:///home/livelihood-korba/Documents/All%20websites/DFM%20korba%20app/lib/services/navigation_service.dart):
- **WhatsApp Links** (`wa.me`, `chat.whatsapp.com`): Automatically opens the installed WhatsApp application with prefilled message.
- **Telephone Calls** (`tel:+916307076206`): Opens the device's native dialer.
- **Email Inquiries** (`mailto:info@dfmkorba.in`): Opens default mail client.
- **Google Maps** (`maps.google.com`, `geo:`): Opens Google Maps / Apple Maps.
- **YouTube & Social Media**: Opens in external browser or dedicated apps.

### B. Session & Cookie Persistence
The Google Apps Script backend stores session tokens (`dfm_token`) in `localStorage`. The WebView is configured with:
- `domStorageEnabled: true`
- `databaseEnabled: true`
- `thirdPartyCookiesEnabled: true` (crucial for Google Apps Script `userCodeAppPanel` iframe)
- `clearCache: false`
Users remain logged in across app restarts.

### C. File Upload & Camera Integration
The Web App contains 19 file inputs for student photos, instructor profiles, assignments, and gallery items. The native wrapper supports:
- Camera capture (`take photo`)
- Image and video gallery selection
- Document picker
- Contextual permissions (requested only when a file picker is opened).

### D. Certificate & PDF Downloads
The in-app certificate generator produces canvas data URLs and Google Drive PDF exports. The [`DownloadService`](file:///home/livelihood-korba/Documents/All%20websites/DFM%20korba%20app/lib/services/download_service.dart):
- Intercepts `data:image/...`, `data:application/pdf...`, and direct HTTP downloads.
- Saves the file to the device storage.
- Displays an interactive SnackBar allowing the user to **Open** (via `open_filex`) or **Share** (via `share_plus`).

### E. Android Back Button Logic
Conforms strictly to Section 7:
1. If WebView has navigation history: `webViewController.goBack()` is triggered.
2. If at the home page (no history): displays the **Exit Confirmation Dialog**:
   > *"Do you want to exit the app? [Cancel] [Exit]"*

### F. Network Offline & Error Resilience
- **Offline Mode**: When internet is lost, [`NoInternetScreen`](file:///home/livelihood-korba/Documents/All%20websites/DFM%20korba%20app/lib/screens/no_internet_screen.dart) appears with a **Retry** button.
- **Loading Failure**: If DNS lookup fails or connection times out, [`ErrorScreen`](file:///home/livelihood-korba/Documents/All%20websites/DFM%20korba%20app/lib/screens/error_screen.dart) provides friendly **Retry** and **Reload** actions without leaking technical stack traces.

---

## 5. Asset Configuration

High-resolution assets have been prepared in:
- `assets/images/dfm_korba_logo.png`: 512x512 branded logo used in the splash screen.
- `assets/images/app_icon.png`: 1024x1024 store-standard application icon.
- `android/app/src/main/res/mipmap-*/ic_launcher.png`: Full set of launcher icon densities (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi).

To replace the logo with a custom organization PNG:
1. Place your transparent logo PNG at `assets/images/dfm_korba_logo.png`.
2. Place your 1024x1024 square icon at `assets/images/app_icon.png`.

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
Or run manually with keytool:
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

Update `android/app/build.gradle` signing configs:
```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile rootProject.file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            ...
        }
    }
}
```

### Step 3: Build Release APK
```bash
flutter build apk --release
```
Artifact path: `build/app/outputs/flutter-apk/app-release.apk`

### Step 4: Build Google Play Android App Bundle (AAB)
```bash
flutter build appbundle --release
```
Artifact path: `build/app/outputs/bundle/release/app-release.aab`

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
1. Select the **Runner** project.
2. In **Signing & Capabilities**, select your **Apple Developer Team**.
3. Confirm Bundle Identifier: `com.dfmkorba.app`.

### Step 3: Build & Archive
```bash
# Build iOS release bundle
flutter build ipa --release
```
Or in Xcode:
1. Select **Product > Destination > Any iOS Device (arm64)**.
2. Select **Product > Archive**.
3. Use Xcode Organizer to distribute to **TestFlight** and the **App Store**.

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
6. **Privacy Policy**: Required by Google Play because the app requests Camera permissions contextually. Provide a link to your institution's privacy statement.
7. **Data Safety Declaration**:
   - Data collection: Minimal (student login credentials and assignment uploads are processed directly by your Google Apps Script backend).
   - Data encrypted in transit: Yes (Strict HTTPS enforced).
   - Camera / Photos: Contextually accessed for profile pictures and assignment uploads.

---

## 9. Apple App Store Submission Guide

1. **Bundle Identifier**: `com.dfmkorba.app`
2. **Category**: Education.
3. **Privacy Information (App Store Connect)**:
   - Camera Usage: Captured in `NSCameraUsageDescription` (Profile pictures and assignment submissions).
   - Photo Library: Captured in `NSPhotoLibraryUsageDescription`.
   - Contact Info: Login credentials submitted to your institution's backend.
4. **App Review Notes**:
   Provide demo student credentials to the Apple Review Team so they can review the authenticated portals without barriers.

---

## 10. Comprehensive Testing Checklist

Before distributing builds to students, verify each test case:

| Test Case | Description | Expected Result | Status |
|---|---|---|---|
| **TC-01** | App Launch & Splash | Dark splash screen appears with logo and transitions smoothly | Pass |
| **TC-02** | Web App Loading | Google Apps Script UI loads without white flash or layout shifts | Pass |
| **TC-03** | Student Login | Login form accepts credentials and authenticates via backend | Pass |
| **TC-04** | Session Persistence | Close and reopen app; student remains logged in via `localStorage` | Pass |
| **TC-05** | Android Back Button | Navigating deep in portal steps back; root displays exit modal | Pass |
| **TC-06** | File Upload (Camera) | Tapping photo upload prompts camera permission and captures photo | Pass |
| **TC-07** | File Upload (Gallery)| Tapping video/file upload opens native gallery/document picker | Pass |
| **TC-08** | Certificate Download | Generating certificate triggers download, save, and open prompt | Pass |
| **TC-09** | WhatsApp Link | Tapping WhatsApp button opens WhatsApp with prefilled message | Pass |
| **TC-10** | Phone Link | Tapping phone number opens native telephone dialer | Pass |
| **TC-11** | Email Link | Tapping email address opens system email client | Pass |
| **TC-12** | Google Maps Link | Tapping location opens Google Maps | Pass |
| **TC-13** | Offline Recovery | Toggling airplane mode displays No Internet view; reconnect reloads | Pass |
| **TC-14** | Pull to Refresh | Swiping down at top of page triggers smooth WebView reload | Pass |
| **TC-15** | Background Resume | Moving app to background and returning preserves exact page state | Pass |

---

## 11. Troubleshooting & Known Limitations

### 1. Google Apps Script Iframe Notice
- **Behavior**: Google Apps Script Web Apps run inside a top-level sandbox (`n-*.script.googleusercontent.com`).
- **Resolution**: `flutter_inappwebview` has `thirdPartyCookiesEnabled: true` and `domStorageEnabled: true` to prevent authentication cookies from being dropped.

### 2. Camera Access in Web Form
- **Behavior**: Modern Android 13+ requires granular media permissions (`READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO`) rather than broad `READ_EXTERNAL_STORAGE`.
- **Resolution**: Both legacy and modern media permissions are configured in `AndroidManifest.xml` with appropriate SDK boundaries.

### 3. App Updates
- **Backend Updates**: Any HTML, CSS, or Apps Script code changes in `Index.html` or `Code.gs` appear **instantly** in the mobile app without requiring a new Play Store / App Store release!
- **Native Wrapper Updates**: A new APK/AAB is only required if native Flutter permissions, icons, or native services change.
