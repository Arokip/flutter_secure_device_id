// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "flutter_secure_device_id",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "flutter_secure_device_id",
            targets: ["flutter_secure_device_id"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "flutter_secure_device_id",
            dependencies: [],
            path: "../Classes",
            sources: ["FlutterSecureDeviceIdPlugin.swift"]
        ),
    ]
)

