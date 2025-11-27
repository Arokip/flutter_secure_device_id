import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_device_id/flutter_secure_device_id_method_channel.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('getDeviceId returns device ID from platform', () async {
    final methodChannel = MethodChannelFlutterSecureDeviceId();
    const MethodChannel channel = MethodChannel('flutter_secure_device_id');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'getDeviceId') {
          return 'test-device-id-hash-1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
        }
        return null;
      },
    );

    expect(await methodChannel.getDeviceId(), 'test-device-id-hash-1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });
}

