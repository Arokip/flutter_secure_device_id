import Flutter
import UIKit
import Security
import CommonCrypto

public class FlutterSecureDeviceIdPlugin: NSObject, FlutterPlugin {
  private let keyTag = "com.com.flutter_secure_device_id".data(using: .utf8)!

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_secure_device_id", binaryMessenger: registrar.messenger())
    let instance = FlutterSecureDeviceIdPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "getDeviceId" {
      if let id = getOrCreateDeviceIdentifier() {
        result(id)
      } else {
        result(FlutterError(code: "ERROR", message: "Failed to get device ID", details: nil))
      }
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

  private func getOrCreateDeviceIdentifier() -> String? {
    // Query for existing private key in keychain
    var query: [String: Any] = [
      kSecClass as String: kSecClassKey,
      kSecAttrApplicationTag as String: keyTag,
      kSecReturnRef as String: true
    ]

    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)

    var publicKey: SecKey?

    if status == errSecSuccess {
      if let key = item as? SecKey {
        publicKey = SecKeyCopyPublicKey(key)
      }
    } else {
      // Create Secure Enclave private key
      let attributes: [String: Any] = [
        kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
        kSecAttrKeySizeInBits as String: 256,
        kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
        kSecPrivateKeyAttrs as String: [
          kSecAttrIsPermanent as String: true,
          kSecAttrApplicationTag as String: keyTag
        ]
      ]

      var error: Unmanaged<CFError>?
      guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
        return nil
      }
      publicKey = SecKeyCopyPublicKey(privateKey)
    }

    guard let pubKey = publicKey else { return nil }

    guard let pubDataCF = SecKeyCopyExternalRepresentation(pubKey, nil) else {
      return nil
    }

    let pubData = pubDataCF as Data

    return sha256Hex(data: pubData)
  }

  private func sha256Hex(data: Data) -> String {
    var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes { ptr in
      _ = CC_SHA256(ptr.baseAddress, CC_LONG(data.count), &hash)
    }
    return hash.map { String(format: "%02x", $0) }.joined()
  }
}

