// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "instagram-clone",
	platforms: [
		.iOS(.v17)
	],
	products: [
		// Products define the executables and libraries a package produces, making them visible to other packages.
		.library(
			name: "ApiRepository",
			targets: ["ApiRepository"]
		),
		.library(
			name: "Env",
			targets: ["Env"]
		),
		.library(
			name: "Shared",
			targets: ["Shared"]
		)
	],
	dependencies: [
	],
	targets: [
		.target(name: "ApiRepository"),
		.target(
			name: "Env",
			resources: [
				.process("Resources/env.debug.plist"),
				.process("Resources/env.staging.plist"),
				.process("Resources/env.production.plist")
			],
			swiftSettings: [
				.define("DEBUG", .when(configuration: .debug)),
				.define("RELEASE", .when(configuration: .release))
			]
		),
		.target(name: "Shared"),
	]
)
