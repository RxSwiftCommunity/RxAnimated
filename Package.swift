// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RxAnimated",
    platforms: [
        .iOS(.v9),
        .tvOS(.v10),
    ],
    products: [
        .library(
            name: "RxAnimated",
            targets: ["RxAnimated"]),
        .library(name: "RxCocoaRuntime", targets: ["RxAnimated"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.1.0")),
    ],
    targets: [
        .target(
            name: "RxAnimated",
            dependencies: [
                "RxSwift",
                "RxCocoa",
            ]),
        .testTarget(
            name: "RxAnimatedTests",
            dependencies: ["RxAnimated","RxSwift",
            "RxCocoa","RxTest", "RxBlocking"]),
    ])
