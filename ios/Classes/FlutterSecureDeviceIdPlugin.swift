import Flutter
import UIKit
import Security
import CommonCrypto

public class FlutterSecureDeviceIdPlugin: NSObject, FlutterPlugin {
  // Use a unique key tag for the Secure Enclave key
  private let keyTag = "com.com.flutter_secure_device_id_key".data(using: .utf8)!
  // Keychain service and account for storing the device ID hash
  // This will persist across app reinstalls if Keychain Access Group is configured
  private let keychainService = "com.com.flutter_secure_device_id"
  private let keychainAccount = "device_id_key"

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
    // Strategy: Use Secure Enclave key as primary source, with Keychain backup
    // The Keychain backup ensures persistence even if Secure Enclave key is lost
    
    // Step 1: Try to get stored device ID from Keychain first (fastest, most reliable)
    if let storedHash = getStoredDeviceIdFromKeychain() {
      // Verify we can still access the Secure Enclave key
      if verifySecureEnclaveKeyExists() {
        return storedHash
      }
      // If Secure Enclave key is lost but we have stored hash, return it
      // This handles the case where key was deleted but hash persists
      return storedHash
    }

    // Step 2: Try to get existing Secure Enclave key
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
      // Step 3: No existing key found, create a new Secure Enclave key
      let attributes: [String: Any] = [
        kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
        kSecAttrKeySizeInBits as String: 256,
        kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
        kSecPrivateKeyAttrs as String: [
          kSecAttrIsPermanent as String: true,
          kSecAttrApplicationTag as String: keyTag,
          // Use ThisDeviceOnly to ensure key is tied to this specific device
          kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
      ]

      var error: Unmanaged<CFError>?
      guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
        // Secure Enclave not available (simulator or old device)
        return nil
      }
      publicKey = SecKeyCopyPublicKey(privateKey)
    }

    guard let pubKey = publicKey else { return nil }

    guard let pubDataCF = SecKeyCopyExternalRepresentation(pubKey, nil) else {
      return nil
    }

    let pubData = pubDataCF as Data
    let hash = sha256Hex(data: pubData)

    // Step 4: Store the hash in Keychain for persistence
    // This ensures the ID persists even if the Secure Enclave key reference is lost
    // Note: For true persistence across app uninstalls, configure Keychain Access Group
    storeDeviceIdInKeychain(hash)

    return hash
  }

  private func verifySecureEnclaveKeyExists() -> Bool {
    let query: [String: Any] = [
      kSecClass as String: kSecClassKey,
      kSecAttrApplicationTag as String: keyTag,
      kSecReturnRef as String: true
    ]
    var item: CFTypeRef?
    return SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess
  }

  private func getStoredDeviceIdFromKeychain() -> String? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: keychainService,
      kSecAttrAccount as String: keychainAccount,
      kSecReturnData as String: true
    ]

    var result: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &result)

    if status == errSecSuccess,
       let data = result as? Data,
       let hash = String(data: data, encoding: .utf8) {
      return hash
    }

    return nil
  }

  private func storeDeviceIdInKeychain(_ hash: String) {
    guard let hashData = hash.data(using: .utf8) else { return }

    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: keychainService,
      kSecAttrAccount as String: keychainAccount,
      kSecValueData as String: hashData,
      // Use ThisDeviceOnly to tie to this specific device
      // For persistence across reinstalls, app must configure Keychain Access Group
      kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    ]

    // Delete existing item if any (update operation)
    SecItemDelete(query as CFDictionary)

    // Add new item
    let addStatus = SecItemAdd(query as CFDictionary, nil)
    if addStatus != errSecSuccess {
      // Log error but don't fail - we still have the Secure Enclave key
      print("Warning: Failed to store device ID in Keychain: \(addStatus)")
    }
  }

  private func sha256Hex(data: Data) -> String {
    var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes { ptr in
      _ = CC_SHA256(ptr.baseAddress, CC_LONG(data.count), &hash)
    }
    return hash.map { String(format: "%02x", $0) }.joined()
  }
}

