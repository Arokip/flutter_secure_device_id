# flutter_secure_device_id

A Flutter plugin that returns a stable, hardware-backed device identifier using Android Keystore (TEE/StrongBox) on Android and Secure Enclave on iOS.

## Why This Approach?

For software licensing and device identification, you need a **stable**, **non-spoofable**, and **hardware-bound** identifier. The common alternatives like `UIDevice.identifierForVendor` (iOS) and `Settings.Secure.ANDROID_ID` (Android) have significant drawbacks:

### ❌ UIDevice.identifierForVendor (iOS)

- **Changes when all apps from the same vendor are uninstalled** and then reinstalled
- **Not hardware-backed** or cryptographically protected
- **Not suitable for licensing** or security-sensitive uses
- Can be reset by users simply uninstalling all apps from your vendor

### ❌ Settings.Secure.ANDROID_ID (Android)

- **May be reset on factory reset** or changes across users/profiles
- **Historically had vendor-specific behavior** and collisions on older devices
- **Not backed by secure hardware** and can be altered on rooted devices
- **Not reliable for licensing** as it can change or be spoofed

### ✅ Hardware-Backed Key Pair Approach (This Plugin)

By generating a **hardware-backed key pair** and hashing its **public key**, this plugin provides:

- ✅ **A unique identifier per device** - The private key stays in secure hardware (TEE/StrongBox on Android, Secure Enclave on iOS)
- ✅ **Strong protections against cloning and spoofing** - The private key never leaves secure hardware
- ✅ **No dangerous permissions required** - No need for READ_PHONE_STATE or other sensitive permissions
- ✅ **Stable across app reinstalls** - The key persists in secure storage
- ✅ **Only resets on device factory reset** - Matches the device lifecycle
- ✅ **Resistant to tampering** - Even on rooted/jailbroken devices, the key remains in secure hardware
- ✅ **App Store/Play Store compliant** - Uses official, recommended APIs
- ✅ **Same architecture on both platforms** - Easy backend validation

## How It Works

### Android
- Generates an RSA key pair in Android Keystore (TEE/StrongBox when available)
- Extracts the public key from the certificate
- Returns SHA-256 hash of the public key bytes

### iOS
- Generates an EC key pair in Secure Enclave
- Stores the private key permanently in Keychain
- Extracts and hashes the public key with SHA-256

Both platforms return a 64-character hexadecimal string (SHA-256 hash).

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_secure_device_id: ^0.1.0
```

## Usage

```dart
import 'package:flutter_secure_device_id/flutter_secure_device_id.dart';

// Get the device ID
try {
  final String deviceId = await FlutterSecureDeviceId.getDeviceId();
  print('Device ID: $deviceId');
} on PlatformException catch (e) {
  print('Failed to get device ID: ${e.message}');
}
```

The `getDeviceId()` method returns a `Future<String>` containing a 64-character hexadecimal string (SHA-256 hash).

## Requirements

### Android
- Minimum SDK: 18 (Android 4.3)
- Recommended: Android 10+ for TEE/StrongBox support
- No special permissions required

### iOS
- Minimum iOS: 11.0
- Secure Enclave support (all modern iPhones/iPads)
- No special permissions required
- **Note**: For persistence across app uninstalls/reinstalls, configure a Keychain Access Group in your app's capabilities. Without this, the device ID will be regenerated after app uninstall (but persists during normal app usage).

## Security Considerations

- The private key **never leaves secure hardware** on either platform
- The identifier is **cryptographically bound** to the device hardware
- **Cannot be cloned** or transferred to another device
- **Resistant to spoofing** even on rooted/jailbroken devices
- Suitable for **software licensing**, **DRM**, and **anti-fraud** use cases

## Backend Validation (Optional)

You can enhance security by validating the device identity on your server:

- **Android**: Use [Key Attestation](https://developer.android.com/training/articles/security-key-attestation) to verify the key was generated in secure hardware
- **iOS**: Use [App Attest](https://developer.apple.com/documentation/devicecheck/establishing-your-app-s-integrity) or [DeviceCheck](https://developer.apple.com/documentation/devicecheck) for additional validation

## Example

See the `example/` directory for a complete example app.

## License

See the LICENSE file for details.
