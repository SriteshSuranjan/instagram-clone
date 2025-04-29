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
			name: "InstagramClient",
			targets: ["InstagramClient"]
		),
		.library(
			name: "InstagramBlocksUI",
			targets: ["InstagramBlocksUI"]
		),
		.library(
			name: "SnackbarMessagesClient",
			targets: ["SnackbarMessagesClient"]
		),
		.library(
			name: "HomeFeature",
			targets: ["HomeFeature"]
		),
		.library(
			name: "FeedFeature",
			targets: ["FeedFeature"]
		),
		.library(
			name: "TimelineFeature",
			targets: ["TimelineFeature"]
		),
		.library(
			name: "ReelsFeature",
			targets: ["ReelsFeature"]
		),
		.library(
			name: "UserProfileFeature",
			targets: ["UserProfileFeature"]
		),
		.library(
			name: "DatabaseClient",
			targets: ["DatabaseClient"]
		),
		.library(
			name: "MediaPickerFeature",
			targets: ["MediaPickerFeature"]
		),
		.library(
			name: "CreatePostFeature",
			targets: ["CreatePostFeature"]
		),
		.library(
			name: "BlurHashClient",
			targets: ["BlurHashClient"]
		),
		.library(
			name: "AppLoadingIndeterminateClient",
			targets: ["AppLoadingIndeterminateClient"]
		),
		.library(
			name: "BottomBarVisiblePreference",
			targets: ["BottomBarVisiblePreference"]
		),
		.library(
			name: "UploadTaskClient",
			targets: ["UploadTaskClient"]
		),
		.library(
			name: "InstaBlocks",
			targets: ["InstaBlocks"]
		),
		.library(
			name: "FirebaseRemoteConfigRepository",
			targets: ["FirebaseRemoteConfigRepository"]
		),
		.library(
			name: "FeedUpdateRequestClient",
			targets: ["FeedUpdateRequestClient"]
		),
		.library(
			name: "PostEditFeature",
			targets: ["PostEditFeature"]
		),
		.library(
			name: "ChatsFeature",
			targets: ["ChatsFeature"]
		),
		.library(
			name: "PostsListFeature",
			targets: ["PostsListFeature"]
		),
		.library(
			name: "PostOptionsSheet",
			targets: ["PostOptionsSheet"]
		),
		.library(
			name: "PostPreviewFeature",
			targets: ["PostPreviewFeature"]
		),
		.library(
			name: "SearchFeature",
			targets: ["SearchFeature"]
		),
		.library(
			name: "CommentsFeature",
			targets: ["CommentsFeature"]
		)
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
		.package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.6.0"),
		.package(url: "https://github.com/pointfreeco/swift-gen.git", from: "0.4.0"),
		.package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.0"),
		.package(url: "https://github.com/Yummypets/YPImagePicker.git", from: "5.0.0"),
		.package(url: "https://github.com/iankoex/UnifiedBlurHash.git", from: "1.0.0"),
		.package(url: "https://github.com/wxxsw/VideoPlayer.git", from: "1.2.4"),
		.package(url: "https://github.com/pointfreeco/swift-sharing.git", from: "2.4.0")
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
		.target(
			name: "Shared",
			dependencies: [
				.product(name: "Tagged", package: "swift-tagged"),
				.product(name: "RswiftLibrary", package: "R.swift"),
			]
		),
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
				"InstagramClient",
				"Env",
				"LaunchFeature",
				"FirebaseCoreClient",
				"SnackbarMessagesClient",
				"HomeFeature",
				"AppLoadingIndeterminateClient",
				"UploadTaskClient",
				"BlurHashClient",
				"Shared",
				"FeedUpdateRequestClient",
				.product(name: "Supabase", package: "supabase-swift"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				.product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
				.product(name: "Sharing", package: "swift-sharing")
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
				"InstagramClient",
				"InstagramBlocksUI",
				"SnackbarMessagesClient",
				"MediaPickerFeature",
				.product(name: "Tagged", package: "swift-tagged"),
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
				"Shared",
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				.product(name: "RswiftLibrary", package: "R.swift"),
				.product(name: "Lottie", package: "lottie-spm"),
				.product(name: "Gen", package: "swift-gen"),
				.product(name: "Kingfisher", package: "Kingfisher"),
				.product(name: "YPImagePicker", package: "YPImagePicker")
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
			name: "InstagramClient",
			dependencies: [
				"Shared",
				"PowerSyncRepository",
				"AuthenticationClient",
				"DatabaseClient",
				"FirebaseRemoteConfigRepository",
				.product(name: "Supabase", package: "supabase-swift"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "InstagramBlocksUI",
			dependencies: [
				"Shared",
				"AppUI",
				"InstaBlocks",
				"BlurHashClient",
				"InstagramClient",
				.product(name: "Kingfisher", package: "Kingfisher"),
				.product(name: "VideoPlayer", package: "VideoPlayer"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "SnackbarMessagesClient",
			dependencies: [
				"Shared",
				.product(name: "Tagged", package: "swift-tagged"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "HomeFeature",
			dependencies: [
				"Shared",
				"AppUI",
				"InstagramBlocksUI",
				"SnackbarMessagesClient",
				"FeedFeature",
				"TimelineFeature",
				"ReelsFeature",
				"UserProfileFeature",
				"InstagramClient",
				"BottomBarVisiblePreference",
				"MediaPickerFeature",
				"CreatePostFeature",
				"ChatsFeature",
				.product(name: "Tagged", package: "swift-tagged"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "FeedFeature",
			dependencies: [
				"Shared",
				"AppUI",
				"InstagramBlocksUI",
				"SnackbarMessagesClient",
				"InstaBlocks",
				"InstagramClient",
				"UserProfileFeature",
				"FeedUpdateRequestClient",
				"PostEditFeature",
				"PostOptionsSheet",
				"CommentsFeature",
				.product(name: "Tagged", package: "swift-tagged"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "TimelineFeature",
			dependencies: [
				"Shared",
				"AppUI",
				"InstagramBlocksUI",
				"SnackbarMessagesClient",
				"InstaBlocks",
				"InstagramClient",
				"PostPreviewFeature",
				"SearchFeature",
				.product(name: "Kingfisher", package: "Kingfisher"),
				.product(name: "VideoPlayer", package: "VideoPlayer"),
				.product(name: "Tagged", package: "swift-tagged"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "ReelsFeature",
			dependencies: [
				"Shared",
				"AppUI",
				"InstagramBlocksUI",
				"SnackbarMessagesClient",
				"InstaBlocks",
				"InstagramClient",
				"CommentsFeature",
				.product(name: "Tagged", package: "swift-tagged"),
				.product(name: "Kingfisher", package: "Kingfisher"),
				.product(name: "VideoPlayer", package: "VideoPlayer"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "UserProfileFeature",
			dependencies: [
				"Shared",
				"AppUI",
				"InstagramBlocksUI",
				"SnackbarMessagesClient",
				"InstagramClient",
				"MediaPickerFeature",
				"InstaBlocks",
				"PostsListFeature",
				"PostPreviewFeature",
				"CommentsFeature",
				.product(name: "UnifiedBlurHash", package: "UnifiedBlurHash"),
				.product(name: "Tagged", package: "swift-tagged"),
				.product(name: "YPImagePicker", package: "YPImagePicker"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "DatabaseClient",
			dependencies: [
				"Shared",
				"PowerSyncRepository",
				.product(
					name: "PowerSync",
					package: "powersync-kotlin"
				),
				.product(
					name: "PowerSyncSQLiteCore",
					package: "powersync-sqlite-core-swift"
				),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.testTarget(
			name: "DatabaseClientTest",
			dependencies: ["DatabaseClient"]
		),
		.target(
			name: "MediaPickerFeature",
			dependencies: [
				"Shared",
				"AppUI",
				"CreatePostFeature",
				"BottomBarVisiblePreference",
				.product(name: "YPImagePicker", package: "YPImagePicker"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "CreatePostFeature",
			dependencies: [
				"Shared",
				"AppUI",
				"UploadTaskClient",
				"InstagramBlocksUI",
				.product(name: "UnifiedBlurHash", package: "UnifiedBlurHash"),
				.product(name: "YPImagePicker", package: "YPImagePicker"),
				.product(name: "Supabase", package: "supabase-swift"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "BlurHashClient",
			dependencies: [
				.product(name: "UnifiedBlurHash", package: "UnifiedBlurHash"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "AppLoadingIndeterminateClient",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				.product(name: "Sharing", package: "swift-sharing")
			]
		),
		.target(name: "BottomBarVisiblePreference"),
		.target(
			name: "UploadTaskClient",
			dependencies: [
				"Shared",
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "InstaBlocks",
			dependencies: [
				"Shared",
			]
		),
		.testTarget(
			name: "InstaBlocksTest",
			dependencies: [
				"InstaBlocks"
			]
		),
		.target(
			name: "FirebaseRemoteConfigRepository",
			dependencies: [
				.product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk")
			]
		),
		.target(
			name: "FeedUpdateRequestClient",
			dependencies: [
				"InstaBlocks",
				"Shared",
					.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "PostEditFeature",
			dependencies: [
				"Shared",
				"AppUI",
				"InstagramBlocksUI",
				"FeedUpdateRequestClient",
				"InstagramClient",
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "ChatsFeature",
			dependencies: [
				"Shared",
				"AppUI",
				"InstagramClient",
				"SearchFeature",
				"InstagramBlocksUI",
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "PostsListFeature",
			dependencies: [
				"Shared",
				"AppUI",
				"InstaBlocks",
				"InstagramBlocksUI",
				"InstagramClient",
				"PostOptionsSheet",
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "PostOptionsSheet",
			dependencies: [
				"AppUI",
				"InstaBlocks",
				"Shared",
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "PostPreviewFeature",
			dependencies: [
				"AppUI",
				"InstaBlocks",
				"InstagramBlocksUI",
				"Shared",
				.product(name: "Kingfisher", package: "Kingfisher"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "SearchFeature",
			dependencies: [
				"AppUI",
				"Shared",
				"InstagramClient",
				"InstagramBlocksUI",
				.product(name: "Kingfisher", package: "Kingfisher"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "CommentsFeature",
			dependencies: [
				"AppUI",
				"Shared",
				"InstagramClient",
				"InstagramBlocksUI",
				"InstaBlocks",
				.product(name: "Kingfisher", package: "Kingfisher"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
	],
	swiftLanguageModes: [.v5]
)
