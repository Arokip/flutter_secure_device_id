import 'dart:async';

import 'package:flutter/services.dart';

import 'flutter_secure_device_id_platform_interface.dart';

/// A Flutter plugin that provides a stable, hardware-backed device identifier
/// for Android (Android Keystore / TEE) and iOS (Secure Enclave).
class FlutterSecureDeviceId {
  FlutterSecureDeviceId._();

  /// Returns a SHA-256 hex string of a hardware-backed public key.
  ///
  /// On Android, this uses Android Keystore (TEE/StrongBox) to generate
  /// a hardware-backed RSA key pair. On iOS, this uses Secure Enclave
  /// to generate an EC key pair. The public key is hashed with SHA-256
  /// and returned as a hex string.
  ///
  /// This identifier is:
  /// - Stable across app reinstalls
  /// - Hardware-bound and cannot be cloned
  /// - Resistant to tampering and spoofing
  /// - Only resets on device factory reset
  ///
  /// Throws a [PlatformException] if the device ID cannot be retrieved.
  static Future<String> getDeviceId() async {
    final String? id = await FlutterSecureDeviceIdPlatform.instance
        .getDeviceId();
    if (id == null) {
      throw PlatformException(
        code: 'ERROR',
        message: 'Failed to get device ID',
      );
    }
    return id;
  }
}
