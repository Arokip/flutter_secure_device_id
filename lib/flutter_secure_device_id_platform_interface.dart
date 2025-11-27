import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_secure_device_id_method_channel.dart';

abstract class FlutterSecureDeviceIdPlatform extends PlatformInterface {
  /// Constructs a FlutterSecureDeviceIdPlatform.
  FlutterSecureDeviceIdPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterSecureDeviceIdPlatform _instance =
      MethodChannelFlutterSecureDeviceId();

  /// The default instance of [FlutterSecureDeviceIdPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterSecureDeviceId].
  static FlutterSecureDeviceIdPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterSecureDeviceIdPlatform] when
  /// they register themselves.
  static set instance(FlutterSecureDeviceIdPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns a SHA-256 hex string of a hardware-backed public key.
  /// Returns null on error.
  Future<String?> getDeviceId() {
    throw UnimplementedError('getDeviceId() has not been implemented.');
  }
}
