import Foundation
import ComposableArchitecture
import FirebaseCoreClient

@Reducer
public struct AppDelegateReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		public init() {
		}
	}
	
	@Dependency(\.firebaseCore) var firebaseCore
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
				return .none
			}
		}
	}
}
