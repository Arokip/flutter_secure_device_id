## 0.3.0

* Support Swift Package Manager

## 0.2.0

* Fix unchanging id

## 0.1.0

* Initial release.
* Android: Hardware-backed device identifier using Android Keystore (TEE/StrongBox)
* iOS: Hardware-backed device identifier using Secure Enclave
* Returns SHA-256 hash of hardware-backed public key as device identifier
* Stable across app reinstalls, only resets on device factory reset
