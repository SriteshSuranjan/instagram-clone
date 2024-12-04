import AppUI
import ComposableArchitecture
import Foundation
import InstagramBlocksUI
import Shared
import SwiftUI
import UserClient

enum ProfileTab: Hashable {
	case posts
	case mentionedPosts
	case followers
	case followings
}

@Reducer
public struct UserProfileReducer {
	@Reducer(state: .equatable)
	public enum Destination {
		case profileSettings(UserProfileSettingsReducer)
		case profileAddMedia(UserProfileAddMediaReducer)
	}

	public init() {}
	@ObservableState
	public struct State: Equatable {
		let authenticatedUserId: String
		let profileUserId: String
		var profileUser: User?
		var profileHeader: UserProfileHeaderReducer.State?
		var activeTab: ProfileTab = .posts
		@Presents var destination: Destination.State?
		public init(authenticatedUserId: String, profileUserId: String) {
			self.authenticatedUserId = authenticatedUserId
			self.profileUserId = profileUserId
		}

		var isOwner: Bool {
			authenticatedUserId == profileUserId
		}
	}

	public enum Action: BindableAction {
		case destination(PresentationAction<Destination.Action>)
		case binding(BindingAction<State>)
		case onTapLogoutButton
		case task
		case profileUser(User)
		case profileHeader(UserProfileHeaderReducer.Action)
		case onTapSettingsButton
		case onTapAddMediaButton
		case onTapMoreButton
	}

	@Dependency(\.userClient.authClient) var authClient
	@Dependency(\.userClient.databaseClient) var databaseClient

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .destination:
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
				if state.profileHeader == nil {
					state.profileHeader = UserProfileHeaderReducer.State(profileUser: user, isOwner: state.isOwner)
				}
				return .none
			case .profileHeader:
				return .none
			case .onTapSettingsButton:
				state.destination = .profileSettings(UserProfileSettingsReducer.State())
				return .none
			case .onTapAddMediaButton:
				state.destination = .profileAddMedia(UserProfileAddMediaReducer.State())
				return .none
			case .onTapMoreButton:
				return .none
			}
		}
		.ifLet(\.profileHeader, action: \.profileHeader) {
			UserProfileHeaderReducer()
		}
		.ifLet(\.$destination, action: \.destination) {
			Destination.body
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
		VStack {
			ScrollView {
				LazyVStack(pinnedViews: [.sectionHeaders]) {
					AppNavigationBar(
						title: store.profileUser?.displayUsername ?? "",
						backButtonAction: nil,
						actions: store.isOwner ? [
							AppNavigationBarTrailingAction(icon: .asset(Assets.Icons.setting.imageResource)) {
								store.send(.onTapSettingsButton)
							},
							AppNavigationBarTrailingAction(icon: .asset(Assets.Icons.addButton.imageResource)) {
								store.send(.onTapAddMediaButton)
							},
						] : [AppNavigationBarTrailingAction(icon: .system("ellipsis")) {
							store.send(.onTapMoreButton)
						}]
					)
					.padding(.horizontal, AppSpacing.md)
					if let headerStore = store.scope(state: \.profileHeader, action: \.profileHeader) {
						UserProfileHeaderView(store: headerStore)
							.padding(AppSpacing.md)
					}
					Section {
						Color.clear.frame(height: 50)
						Text("Posts")
					} header: {
						VStack(spacing: 0) {
							ScrollTabBarView(selection: $store.activeTab) {
								AppUI.TabItem(ProfileTab.posts) {
									Image(systemName: "squareshape.split.3x3")
								}
								AppUI.TabItem(ProfileTab.mentionedPosts) {
									Image(systemName: "person")
								}
							}
						}
					}
				}
			}
			.scrollIndicators(.hidden)
		}
		.coverStatusBar()
		.sheet(item: $store.scope(state: \.destination?.profileSettings, action: \.destination.profileSettings)) { profileSettingsStore in
			UserProfileSettingsView(store: profileSettingsStore)
				.presentationDetents([.height(240)])
				.presentationDragIndicator(.visible)
				.padding(.horizontal, AppSpacing.sm)
		}
		.sheet(item: $store.scope(state: \.destination?.profileAddMedia, action: \.destination.profileAddMedia)) { profileAddMediaStore in
			UserProfileAddMediaView(store: profileAddMediaStore)
				.presentationDetents([.height(280)])
				.presentationDragIndicator(.visible)
				.padding(.horizontal, AppSpacing.sm)
		}
		.task {
			await store.send(.task).finish()
		}
	}
}

//			Button(role: .destructive) {
//				store.send(.onTapLogoutButton)
//			} label: {
//				Text("UserProfile")
//					.font(textTheme.headlineSmall.font)
//			}
//			.buttonStyle(.borderedProminent)
