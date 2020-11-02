// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Transition",
    products: [
        .library(
            name: "Transition",
            targets: ["Transition"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Transition",
            path: "Transition/Classes")
    ]
)
