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
		),
		.library(
			name: "PowerSyncRepository",
			targets: ["PowerSyncRepository"]
		),
		.library(
			name: "AppFeature",
			targets: ["AppFeature"]
		),
		.library(
			name: "ComposableUserNotifications",
			targets: ["ComposableUserNotifications"]
		),
		.library(
			name: "AuthFeature",
			targets: ["AuthFeature"]
		),
		.library(
			name: "FirebaseCoreClient",
			targets: ["FirebaseCoreClient"]
		),
		.library(
			name: "AppUI",
			targets: ["AppUI"]
		),
		.library(
			name: "LaunchFeature",
			targets: ["LaunchFeature"]
		),
		.library(
			name: "ValidatorClient",
			targets: ["ValidatorClient"]
		),
		.library(
			name: "AuthenticationClient",
			targets: ["AuthenticationClient"]
		),
		.library(
			name: "UserClient",
			targets: ["UserClient"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/powersync-ja/powersync-kotlin", exact: "1.0.0-BETA5.0"),
		.package(url: "https://github.com/powersync-ja/powersync-sqlite-core-swift", branch: "main"),
		.package(url: "https://github.com/supabase/supabase-swift.git", from: "2.23.0"),
		.package(url: "https://github.com/tgrapperon/swift-dependencies-additions.git", from: "1.1.1"),
		.package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.16.1"),
		.package(url: "https://github.com/Flight-School/AnyCodable", from: "0.6.0"),
		.package(url: "https://github.com/firebase/firebase-ios-sdk", .upToNextMajor(from: "10.4.0")),
		.package(url: "https://github.com/google/GoogleSignIn-iOS", from: "7.0.0"),
		.package(url: "https://github.com/mac-cain13/R.swift.git", from: "7.0.0"),
		.package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.5.0"),
		.package(url: "https://github.com/exyte/SVGView.git", from: "1.0.6"),
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
		.target(name: "LaunchFeature", dependencies: ["AppUI"]),
		.target(
			name: "PowerSyncRepository",
			dependencies: [
				"Env",
				.product(name: "AnyCodable", package: "AnyCodable"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				.product(name: "DependenciesAdditions", package: "swift-dependencies-additions"),
				.product(
					name: "PowerSync",
					package: "powersync-kotlin"
				),
				.product(
					name: "PowerSyncSQLiteCore",
					package: "powersync-sqlite-core-swift"
				),
				.product(name: "Supabase", package: "supabase-swift"),
			]
		),
		.target(
			name: "AppFeature",
			dependencies: [
				"AuthFeature",
				"UserClient",
				"Env",
				"LaunchFeature",
				"FirebaseCoreClient",
				.product(name: "Supabase", package: "supabase-swift"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				.product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
			]
		),
		.target(
			name: "ComposableUserNotifications",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "AuthFeature",
			dependencies: [
				"AppUI",
				"ValidatorClient",
				"Shared",
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "ValidatorClient",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "FirebaseCoreClient",
			dependencies: [
				.product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "AppUI",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				.product(name: "RswiftLibrary", package: "R.swift"),
				.product(name: "Lottie", package: "lottie-spm"),
				.product(name: "SVGView", package: "SVGView"),
			],
			resources: [
				.process("Resources/Images/Images.xcassets"),
				.process("Resources/Icons/Icons.xcassets"),
				.process("Resources/Fonts"),
				.process("Resources/Animations"),
				.process("Resources/Colors/Colors.xcassets"),
			],
			plugins: [.plugin(name: "RswiftGeneratePublicResources", package: "R.swift")]
		),
		.target(
			name: "AuthenticationClient",
			dependencies: [
				"Shared",
				"PowerSyncRepository",
				.product(name: "Supabase", package: "supabase-swift"),
				.product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "UserClient",
			dependencies: [
				"Shared",
				"PowerSyncRepository",
				"AuthenticationClient",
				.product(name: "Supabase", package: "supabase-swift"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
	],
	swiftLanguageVersions: [.v6]
)
