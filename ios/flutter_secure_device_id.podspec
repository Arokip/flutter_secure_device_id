#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_secure_device_id.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_secure_device_id'
  s.version          = '0.1.0'
  s.summary          = 'A Flutter plugin for hardware-backed device identifier (Android Keystore & iOS Secure Enclave)'
  s.description      = <<-DESC
A Flutter plugin that returns a stable, hardware-backed device identifier using Android Keystore (TEE/StrongBox) on Android and Secure Enclave on iOS.
                       DESC
  s.homepage         = 'https://github.com/Arokip/flutter_secure_device_id'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Arokip' => '' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'flutter_secure_device_id_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end

