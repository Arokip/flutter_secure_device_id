import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_secure_device_id_platform_interface.dart';

/// An implementation of [FlutterSecureDeviceIdPlatform] that uses method channels.
class MethodChannelFlutterSecureDeviceId extends FlutterSecureDeviceIdPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_secure_device_id');

  @override
  Future<String?> getDeviceId() async {
    final id = await methodChannel.invokeMethod<String>('getDeviceId');
    return id;
  }
}
