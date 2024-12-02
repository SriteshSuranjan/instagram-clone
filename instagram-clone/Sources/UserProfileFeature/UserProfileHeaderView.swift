import AppUI
import ComposableArchitecture
import Foundation
import InstagramBlocksUI
import Shared
import SwiftUI
import UserClient

@Reducer
public struct UserProfileHeaderReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var profileUser: User
		var isOwner: Bool
		var postsCount: Int = 0
		var followersCount: Int = 0
		var followingsCount: Int = 0
		public init(profileUser: User, isOwner: Bool) {
			self.profileUser = profileUser
			self.isOwner = isOwner
		}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case task
		case postsCountSubscription(Int)
		case followersCountSubscription(Int)
		case followingsCountSubscription(Int)
	}

	@Dependency(\.userClient.databaseClient) var databaseClient

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .task:
				return .run { @MainActor [userId = state.profileUser.id] send in
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
					_ = await (postsCount, followersCount, followingsCount)
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
			}
		}
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
				AvatarImageView(
					title: store.profileUser.avatarName,
					size: .large,
					url: nil
				)
				Group {
					UserProfileStatistics(name: "Posts", value: $store.postsCount) {}
					UserProfileStatistics(name: "Followers", value: $store.followersCount) {}
					UserProfileStatistics(name: "Followings", value: $store.followingsCount) {}
				}
				.frame(maxWidth: .infinity)
			}
			.frame(maxWidth: .infinity)

			Text(store.profileUser.displayFullName)
				.font(textTheme.titleLarge.font)
				.frame(maxWidth: .infinity, alignment: .leading)
			HStack(spacing: AppSpacing.sm) {
				if store.isOwner {
					FlexibleRowLayout {
						EditProfileButton {}
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
					UserProfileFollowUserButton(isFollowed: true, user: store.profileUser) {}
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
