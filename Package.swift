// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "roku-app",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0")
    ],
    targets: [
        .target(
            name: "roku-app",
            dependencies: ["Alamofire"]
        )
    ]
)
