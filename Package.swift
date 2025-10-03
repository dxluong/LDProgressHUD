// swift-tools-version:5.3
 
import PackageDescription

let package = Package(
    name: "LDProgressHUD",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "LDProgressHUD",
            targets: ["LDProgressHUD"]
        )
    ],
    targets: [
        .target(
            name: "LDProgressHUD",
            dependencies: [],
            path: "LDProgressHUD",
            resources: [
                .copy("LDProgressHUD.bundle"),
                .copy("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)

