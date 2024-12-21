import Foundation
import ComposableArchitecture
import FirebaseCoreClient
import InstagramClient

@Reducer
public struct AppDelegateReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		public init() {
		}
	}
	
	@Dependency(\.firebaseCore) var firebaseCore
	@Dependency(\.instagramClient.firebaseRemoteConfigClient) var firebaseRemoteConfigClient
	
	public enum Action {
		case didFinishLaunching
//		case didRegisterForRemoteNotifications(Result<Data, Error>)
//		case userNotifications(UserNotificationClient.DelegateEvent)
	}
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
			case .didFinishLaunching:
				firebaseCore.config()
				return .run { _ in
					try await firebaseRemoteConfigClient.config()
				} catch: { error, send in
					
				}
			}
		}
	}
}
