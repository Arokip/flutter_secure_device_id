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

    if (!keyStore.containsAlias(KEY_ALIAS)) {
      val kpg = KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_RSA, "AndroidKeyStore")

      val specBuilder = KeyGenParameterSpec.Builder(
        KEY_ALIAS,
        KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY
      ).apply {
        setDigests(KeyProperties.DIGEST_SHA256)
        // Do not require user authentication by default. Adjust if you need user auth.
        setUserAuthenticationRequired(false)
        // Attestation challenge can be set if you want attestation certs generated
        // setAttestationChallenge("attestation-challenge".toByteArray())
      }

      kpg.initialize(specBuilder.build())
      kpg.generateKeyPair()
    }

    val cert = keyStore.getCertificate(KEY_ALIAS)
      ?: throw RuntimeException("Failed to get certificate for alias")

    val publicKeyBytes = cert.publicKey.encoded

    val digest = MessageDigest.getInstance("SHA-256")
    val hash = digest.digest(publicKeyBytes)

    return hash.joinToString(separator = "") { byte -> "%02x".format(byte) }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}

