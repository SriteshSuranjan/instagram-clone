import AppFeature
import AppUI
import AuthenticationClient
import ComposableArchitecture
import Env
import GoogleSignIn
import PowerSyncRepository
import SwiftUI
import UserClient

final class AppDelegate: NSObject, UIApplicationDelegate {
	let store: StoreOf<AppReducer>
	override init() {
		let env = Envionment.current

		// Initialize PowerSyncRepository

		let powerSyncRepository = PowerSyncRepository.instanceWithInitilized(env: env)
		// Initialize TokenStorage
		let tokenStorage = InMemoryTokenStorage()

		// Initialize GIDSignIn
		let googleSignIn = GIDSignIn.sharedInstance

		// Initialize SupabaseAuthenticationClient
		let authClient = SupabaseAuthenticationClient(
			powerSyncRepository: powerSyncRepository,
			tokenStorage: tokenStorage,
			googleSignIn: googleSignIn
		)

		self.store = Store(
			initialState: AppReducer.State()
		) {
			AppReducer()
				.transformDependency(\.self) {
					$0.userClient = .liveSupabaseAuthenticationClient(
						authClient
					)
				}
		}

		super.init()
	}

	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
	) -> Bool {
		self.store.send(.appDelegate(.didFinishLaunching))
		return true
	}

//	func application(
//		_ application: UIApplication,
//		didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
//	) {
//		self.store.send(.appDelegate(.didRegisterForRemoteNotifications(.success(deviceToken))))
//	}
//
//	func application(
//		_ application: UIApplication,
//		didFailToRegisterForRemoteNotificationsWithError error: Error
//	) {
//		self.store.send(.appDelegate(.didRegisterForRemoteNotifications(.failure(error))))
//	}
}

@main
struct SwiftInstagramCloneApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
	init() {
		AppUI.registerFonts()
	}

	@Environment(\.textTheme) var textTheme

	var body: some Scene {
		WindowGroup {
			AppView(store: self.appDelegate.store)
				.environment(\.textTheme, self.textTheme)
		}
	}
}
