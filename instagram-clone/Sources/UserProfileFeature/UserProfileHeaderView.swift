import AppUI
import ComposableArchitecture
import Foundation
import InstagramBlocksUI
import Shared
import SwiftUI
import InstagramClient

@Reducer
public struct UserProfileHeaderReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable, Identifiable {
		var profileUserId: String
		var isOwner: Bool
		var postsCount: Int = 0
		var followersCount: Int = 0
		var followingsCount: Int = 0
		var isFollowing: Bool?
		var profileUser: User?
		public init(profileUserId: String, isOwner: Bool) {
			self.profileUserId = profileUserId
			self.isOwner = isOwner
		}
		public var id: String {
			profileUserId
		}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case task
		case postsCountSubscription(Int)
		case followersCountSubscription(Int)
		case followingsCountSubscription(Int)
		case followingStatusSubscription(Bool)
		case profileUserInfoSubscription(User)
		case onTapFollowButton
		case delegate(Delegate)
		public enum Delegate {
			case onTapStatistics(Int)
			case onTapEditProfileButton
		}
	}

	public enum Cancel: Hashable {
		case subscriptions
	}

	@Dependency(\.instagramClient.databaseClient) var databaseClient

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .task:
				return .run { @MainActor [isOwner = state.isOwner, userId = state.profileUserId] send in
					await withTaskCancellation(id: Cancel.subscriptions, cancelInFlight: true) {
						await subscriptions(send: send, userId: userId, isOwner: isOwner)
					}
				}
			case let .postsCountSubscription(postCount):
				state.postsCount = postCount
				return .none
			case let .followersCountSubscription(followersCount):
				state.followersCount = followersCount
				return .none
			case let .followingsCountSubscription(followingsCount):
				state.followingsCount = followingsCount
				return .none
			case let .followingStatusSubscription(isFollowing):
				state.isFollowing = isFollowing
				return .none
			case .delegate:
				return .none
			case .onTapFollowButton:
				return .run { [userId = state.profileUserId] _ in
					try await databaseClient.follow(followedToId: userId, followerId: nil)
				}
			case let .profileUserInfoSubscription(user):
				state.profileUser = user
				return .none
			}
		}
	}

	private func subscriptions(send: Send<Action>, userId: String, isOwner: Bool) async {
		async let userProfile: Void = {
			for await userProfile in await databaseClient.profile(userId) {
				await send(.profileUserInfoSubscription(userProfile))
			}
		}()
		async let followingStatus: Void = {
			let currentUserId = await databaseClient.currentUserId().lowercased()
			for await isFollowing in await databaseClient.followingStatus(userId: userId, followerId: currentUserId) {
				await send(.followingStatusSubscription(isFollowing))
			}
		}()
		async let postsCount: Void = {
			for await postsCount in await databaseClient.postsCount(userId) {
				await send(.postsCountSubscription(postsCount), animation: .bouncy)
			}
		}()
		async let followersCount: Void = {
			for await followers in await databaseClient.followersCount(userId) {
				await send(.followersCountSubscription(followers), animation: .bouncy)
			}
		}()
		async let followingsCount: Void = {
			for await followings in await databaseClient.followingsCount(userId) {
				await send(.followingsCountSubscription(followings), animation: .bouncy)
			}
		}()
		_ = await (userProfile, followingStatus, postsCount, followersCount, followingsCount)
	}
}

public struct UserProfileHeaderView: View {
	@Bindable var store: StoreOf<UserProfileHeaderReducer>
	@Environment(\.textTheme) var textTheme
	public init(store: StoreOf<UserProfileHeaderReducer>) {
		self.store = store
	}

	public var body: some View {
		VStack(spacing: AppSpacing.md) {
			HStack {
				UserProfileAvatar(
					userId: store.profileUserId,
					avatarUrl: store.profileUser?.avatarUrl
				)
				Group {
					UserProfileStatistics(name: "Posts", value: $store.postsCount) {
						store.send(.delegate(.onTapStatistics(0)))
					}
					UserProfileStatistics(name: "Followers", value: $store.followersCount) {
						store.send(.delegate(.onTapStatistics(1)))
					}
					UserProfileStatistics(name: "Followings", value: $store.followingsCount) {
						store.send(.delegate(.onTapStatistics(2)))
					}
				}
				.frame(maxWidth: .infinity)
			}
			.frame(maxWidth: .infinity)

			Text(store.profileUser?.displayFullName ?? "")
				.font(textTheme.titleLarge.font)
				.frame(maxWidth: .infinity, alignment: .leading)
			HStack(spacing: AppSpacing.sm) {
				if store.isOwner {
					FlexibleRowLayout {
						EditProfileButton {
							store.send(.delegate(.onTapEditProfileButton))
						}
						.flex(3)
						.frame(maxHeight: .infinity)
						ShareProfileButton {}
							.flex(3)
							.frame(maxHeight: .infinity)
						ShowSuggestedPeopleButton {}
							.flex(1)
							.frame(maxHeight: .infinity)
					}
				} else {
					if let profileUser = store.profileUser {
						UserProfileFollowUserButton(isFollowed: store.isFollowing ?? false, user: profileUser) {
							store.send(.onTapFollowButton)
						}
					}
				}
			}
		}
		.task {
			await store.send(.task).finish()
		}
	}
}

public struct EditProfileButton: View {
	let action: () -> Void
	public init(action: @escaping () -> Void) {
		self.action = action
	}

	public var body: some View {
		UserProfileButton<EmptyView>(
			label: "Edit profile",
			action: action
		)
	}
}

public struct ShareProfileButton: View {
	let action: () -> Void
	public init(action: @escaping () -> Void) {
		self.action = action
	}

	public var body: some View {
		UserProfileButton<EmptyView>(
			label: "Share profile",
			action: action
		)
	}
}

public struct ShowSuggestedPeopleButton: View {
	let action: () -> Void
	public init(action: @escaping () -> Void) {
		self.action = action
	}

	@State private var showPeople = false
	public var body: some View {
		UserProfileButton(
			content: {
				showPeople ? Image(systemName: "person.badge.plus.fill").symbolRenderingMode(.hierarchical) : Image(systemName: "person.badge.plus").symbolRenderingMode(.hierarchical)
			},
			action: { withAnimation {
				showPeople.toggle()
			} }
		)
	}
}

public struct UserProfileFollowUserButton: View {
	let isFollowed: Bool
	let user: User
	let action: () -> Void
	@Environment(\.colorScheme) var colorScheme
	public init(isFollowed: Bool, user: User, action: @escaping () -> Void) {
		self.isFollowed = isFollowed
		self.user = user
		self.action = action
	}

	public var body: some View {
		UserProfileButton<EmptyView>(
			label: isFollowed ? "Following ▼" : "Follow",
			color: Assets.Colors.customReversedAdaptiveColor(colorScheme, light: Assets.Colors.lightBlue, dark: Assets.Colors.blue),
			action: action
		)
	}
}
