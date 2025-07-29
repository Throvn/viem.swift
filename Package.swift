// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Viem",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Viem",
            targets: ["Viem"]),
    ],
	dependencies: [
		.package(url: "https://github.com/Boilertalk/secp256k1.swift.git", from: "0.1.7")],
    targets: [
		.target(
			name: "Keccak",
			path: "Sources/Keccak",
			publicHeadersPath: "."
		),
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
			name: "Viem",
			dependencies: ["Keccak",
				.product(name: "secp256k1", package: "secp256k1.swift"),
		  ]
		),

    ]
)
