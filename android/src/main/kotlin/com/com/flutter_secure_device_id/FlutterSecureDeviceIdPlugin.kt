package com.com.flutter_secure_device_id

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.MessageDigest

class FlutterSecureDeviceIdPlugin: FlutterPlugin, MethodChannel.MethodCallHandler {
  private lateinit var channel : MethodChannel
  private val KEY_ALIAS = "flutter_secure_device_id_key"

  override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(binding.binaryMessenger, "flutter_secure_device_id")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    if (call.method == "getDeviceId") {
      try {
        val id = getOrCreateDeviceIdentifier()
        result.success(id)
      } catch (e: Exception) {
        result.error("ERROR", e.message, null)
      }
    } else {
      result.notImplemented()
    }
  }

  private fun getOrCreateDeviceIdentifier(): String {
    val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }

    // Check if key already exists
    if (!keyStore.containsAlias(KEY_ALIAS)) {
      // Key doesn't exist, create a new one
      // This key will persist across app reinstalls as it's stored in Android Keystore
      val kpg = KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_RSA, "AndroidKeyStore")

      val specBuilder = KeyGenParameterSpec.Builder(
        KEY_ALIAS,
        KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY
      ).apply {
        setDigests(KeyProperties.DIGEST_SHA256)
        // Do not require user authentication - key must be accessible without user interaction
        setUserAuthenticationRequired(false)
        // Key validity period - set to maximum to ensure it never expires
        setKeyValidityStart(java.util.Date())
        // Attestation challenge can be set if you want attestation certs generated
        // setAttestationChallenge("attestation-challenge".toByteArray())
      }

      kpg.initialize(specBuilder.build())
      kpg.generateKeyPair()
    }

    // Retrieve the certificate and extract public key
    val cert = keyStore.getCertificate(KEY_ALIAS)
      ?: throw RuntimeException("Failed to get certificate for alias")

    val publicKeyBytes = cert.publicKey.encoded

    // Hash the public key to create a stable device identifier
    val digest = MessageDigest.getInstance("SHA-256")
    val hash = digest.digest(publicKeyBytes)

    // Return as hex string - this will be the same every time for this device
    return hash.joinToString(separator = "") { byte -> "%02x".format(byte) }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}

