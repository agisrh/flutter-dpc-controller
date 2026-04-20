# DeviceAdminManager 🛡️

A powerful Flutter plugin for Android Enterprise and Device Administration. This plugin allows you to manage device-level policies, restrict hardware features, enable kiosk mode, and enforce security protocols on Android devices.

## 🚀 Features

*   **🔒 Device Security**: Lock device, wipe data, and manage factory reset protection.
*   **🛠️ Kiosk Mode**: Pin applications to the screen (Kiosk Mode) and set a custom launcher.
*   **📷 Hardware Control**: Disable/Enable camera, screen capture, and safe boot.
*   **⚙️ System Restrictions**: Disable ADB interactions, prevent app uninstallation, and manage user restrictions.
*   **💡 Screen Management**: Keep screen awake and manage keyguard (lock screen) status.
*   **📡 Boot Events**: Handle background logic immediately after the device finishes booting.

---

## 📦 Installation

Add `device_admin_manager` to your `pubspec.yaml`:

```yaml
dependencies:
  device_admin_manager:
    path: ../ # or latest version from pub.dev
```

---

## 🤖 Android Setup

### 1. Register DeviceAdminReceiver
Add the following `<receiver>` inside the `<application>` tag in your `android/app/src/main/AndroidManifest.xml`:

```xml
<receiver
    android:name="com.ib.device_admin_manager.AppDeviceAdminReceiver"
    android:label="Device Admin"
    android:description="@string/app_name"
    android:permission="android.permission.BIND_DEVICE_ADMIN"
    android:exported="true">
    <meta-data
        android:name="android.app.device_admin"
        android:resource="@xml/device_admin_receiver" />
    <intent-filter>
        <action android:name="android.app.action.DEVICE_ADMIN_ENABLED" />
        <action android:name="android.intent.action.BOOT_COMPLETED" />
    </intent-filter>
</receiver>
```

### 2. Define Admin Policies
Ensure you have the policy file at `android/app/src/main/res/xml/device_admin_receiver.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<device-admin xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-policies>
        <limit-password />
        <watch-login />
        <reset-password />
        <force-lock />
        <wipe-data />
        <disable-keyguard-features />
        <encrypted-storage />
        <disable-camera />
    </uses-policies>
</device-admin>
```

---

## 🔑 Provisioning (Device Owner)

Some features (like wiping data, disabling ADB, or pinning the app) require **Device Owner** status.

### Method 1: ADB (Development)
1. Remove all accounts (Google, etc.) from the device.
2. Run the following command:
```bash
adb shell dpm set-device-owner YOUR_PACKAGE_NAME/com.ib.device_admin_manager.AppDeviceAdminReceiver
```
*Example: `adb shell dpm set-device-owner com.example.app/com.ib.device_admin_manager.AppDeviceAdminReceiver`*

### Method 2: QR Code (Production)
Factory reset the device and tap the "Welcome" screen 6 times to scan a provisioning QR code.

---

## 💻 Usage

### Initialize and Request Privileges
```dart
import 'package:device_admin_manager/device_manager.dart';

final dam = DeviceAdminManager.instance;

// Request admin activation if not already active
bool success = await dam.requestAdminPrivilegesIfNeeded();
```

### Enable Kiosk Mode
```dart
// Lock the app as the default launcher
await dam.lockApp(home: true);

// Unlock the app
await dam.unlockApp();
```

### Hardware Restrictions
```dart
// Disable Camera
await dam.setCameraDisabled(disabled: true);

// Disable Screen Capture
await dam.setScreenCaptureDisabled(disabled: true);
```

### Wipe Device Data
```dart
// Factory reset the device
await dam.wipeData();
```

---

## ⚠️ Important Notes

> [!WARNING]
> **Persistence**: Device Owner status is highly persistent. It cannot be uninstalled normally. You must call `clearDeviceOwnerApp()` or factory reset the device to remove it.

> [!NOTE]
> Ensure your app targets the appropriate Android API level. Some features require Android 5.0 (API 21) or higher.

## 📄 License
This project is licensed under the MIT License.
