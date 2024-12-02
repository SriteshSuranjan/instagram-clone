import Foundation
import SwiftUI
import ComposableArchitecture
import AppUI
import UserClient
import Shared

@Reducer
public struct UserProfileReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		let authenticatedUserId: String
		let profileUserId: String
		var profileUser: User?
		public init(authenticatedUserId: String, profileUserId: String) {
			self.authenticatedUserId = authenticatedUserId
			self.profileUserId = profileUserId
		}
		var isOwnder: Bool {
			authenticatedUserId == profileUserId
		}
	}
	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case onTapLogoutButton
		case task
		case profileUser(User)
	}
	
	@Dependency(\.userClient.authClient) var authClient
	@Dependency(\.userClient.databaseClient) var databaseClient
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .onTapLogoutButton:
				return .run { _ in
					try await authClient.logOut()
				}
			case .task:
				return .run { [profileUserId = state.profileUserId] send in
					async let profileUser: Void = {
						for await user in await databaseClient.profile(profileUserId) {
							await send(.profileUser(user))
						}
					}()
					_ = await profileUser
				}
			case let .profileUser(user):
				state.profileUser = user
				return .none
			}
		}
	}
}

public struct UserProfileView: View {
	@Bindable var store: StoreOf<UserProfileReducer>
	@Environment(\.textTheme) var textTheme
	public init(store: StoreOf<UserProfileReducer>) {
		self.store = store
	}
	public var body: some View {
		ScrollView {
			LazyVStack {
				AppNavigationBar(
					title: store.profileUser?.displayUsername ?? "",
					backButtonAction: nil,
					actions: [
						AppNavigationBarTrailingAction(icon: .system("gearshape")) {
							
						},
						AppNavigationBarTrailingAction(icon: .system("plus.app")) {
							
						},
					]
				)
				.padding(.horizontal, AppSpacing.md)
			}
			Button(role: .destructive) {
				store.send(.onTapLogoutButton)
			} label: {
				Text("UserProfile")
					.font(textTheme.headlineSmall.font)
			}
			.buttonStyle(.borderedProminent)
		}
		.task {
			await store.send(.task).finish()
		}
		
	}
}



