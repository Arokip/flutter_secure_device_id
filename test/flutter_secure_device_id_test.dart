import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_device_id/flutter_secure_device_id.dart';
import 'package:flutter_secure_device_id/flutter_secure_device_id_platform_interface.dart';
import 'package:flutter_secure_device_id/flutter_secure_device_id_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterSecureDeviceIdPlatform
    with MockPlatformInterfaceMixin
    implements FlutterSecureDeviceIdPlatform {

  @override
  Future<String?> getDeviceId() => Future.value('test-device-id-hash-1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef');
}

void main() {
  final FlutterSecureDeviceIdPlatform initialPlatform = FlutterSecureDeviceIdPlatform.instance;

  test('$MethodChannelFlutterSecureDeviceId is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterSecureDeviceId>());
  });

  test('getDeviceId', () async {
    MockFlutterSecureDeviceIdPlatform fakePlatform = MockFlutterSecureDeviceIdPlatform();
    FlutterSecureDeviceIdPlatform.instance = fakePlatform;

    expect(await FlutterSecureDeviceId.getDeviceId(), 'test-device-id-hash-1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef');
  });
}

