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
	let store = Store(
		initialState: AppReducer.State()
	) {
		AppReducer()
			.transformDependency(\.self) {
				if let powerSyncRepository = PowerSyncRepository(env: Envionment.current) {
					$0.userClient = .liveSupabaseAuthenticationClient(
						SupabaseAuthenticationClient(
							powerSyncRepository: powerSyncRepository,
							tokenStorage: InMemoryTokenStorage(),
							googleSignIn: GIDSignIn.sharedInstance
						),
						supabaseClient: powerSyncRepository.supabase
					)
				} else {
					$0.userClient = .liveValue
				}
			}
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
