import AppUI
import ComposableArchitecture
//import CreatePostFeature
import Foundation
import InstagramBlocksUI
import MediaPickerFeature
import Shared
import SwiftUI
import UserClient
import YPImagePicker

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
		case mediaPicker(MediaPickerReducer)
		case userStatistics(UserStatisticsReducer)
	}

	public init() {}
	@ObservableState
	public struct State: Equatable, Identifiable {
		let authenticatedUserId: String
		let profileUserId: String
		var profileUser: User?
		var profileHeader: UserProfileHeaderReducer.State?
		var activeTab: ProfileTab = .posts
		@Presents var destination: Destination.State?
		var showBackButton: Bool
		public init(authenticatedUserId: String, profileUserId: String, showBackButton: Bool = false) {
			self.authenticatedUserId = authenticatedUserId
			self.profileUserId = profileUserId
			self.showBackButton = showBackButton
			debugPrint(profileUserId, showBackButton, #line)
		}

		var isOwner: Bool {
			authenticatedUserId == profileUserId
		}

		public var id: String {
			profileUserId
		}
	}

	public indirect enum Action: BindableAction {
		case destination(PresentationAction<Destination.Action>)
		case binding(BindingAction<State>)
		case onTapLogoutButton
		case task
		case profileUser(User)
		case profileHeader(UserProfileHeaderReducer.Action)
		case onTapSettingsButton
		case onTapAddMediaButton
		case onTapMoreButton
		case onTapBackButton
	}

	@Dependency(\.userClient.authClient) var authClient
	@Dependency(\.userClient.databaseClient) var databaseClient

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce{ state, action in
			switch action {
			case .binding:
				return .none
			case .destination(.presented(.mediaPicker(.delegate(.createPostPopToRoot)))):
				state.destination = nil
				return .none
			case let .destination(.presented(.profileAddMedia(.delegate(.onTapAddMediaButton(mediaType))))):
				let isReels = mediaType == .reels
				state.destination = .mediaPicker(MediaPickerReducer.State(pickerConfiguration: MediaPickerView.Configuration(maxItems: 10, reels: isReels)))
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
			case let .profileHeader(.delegate(.onTapStatistics(tabIndex))):
				guard let profileUser = state.profileUser else {
					return .none
				}
				guard tabIndex > 0 else {
					// TODO: route to posts
					return .none
				}
				guard let selectedTab = UserStatisticsTab(rawValue: tabIndex) else {
					return .none
				}
				let userStatisticsState = UserStatisticsReducer.State(authUserId: state.authenticatedUserId, user: profileUser, selectedTab: selectedTab)
				state.destination = .userStatistics(userStatisticsState)
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
			case .onTapBackButton:
				return .run { _ in
					@Dependency(\.dismiss) var dismiss
					await dismiss()
				}
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
				AppNavigationBar(
					title: store.profileUser?.displayUsername ?? "",
					backButtonAction: store.showBackButton ? {
						store.send(.onTapBackButton)
					} : nil,
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
				LazyVStack(pinnedViews: [.sectionHeaders]) {
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
		.navigationDestination(item: $store.scope(state: \.destination?.userStatistics, action: \.destination.userStatistics)) { userStatisticsStore in
			UserStatisticsView(store: userStatisticsStore)
		}
		.navigationDestination(item: $store.scope(state: \.destination?.mediaPicker, action: \.destination.mediaPicker)) { mediaPickerStore in
			MediaPicker(store: mediaPickerStore)
		}
		.toolbar(.hidden, for: .navigationBar)
		.task {
			await store.send(.task).finish()
		}
	}
}
