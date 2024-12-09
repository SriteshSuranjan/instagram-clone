import Foundation
import SwiftUI
import ComposableArchitecture
import DatabaseClient
import Shared
import UserClient
import AppUI
import InstagramBlocksUI

@Reducer
public struct UserProfileListTileReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable, Identifiable {
		var profileUserId: String // Previous List user id
		var user: User // tile user
		var follower: Bool
		var authUserId: String
		var isMe: Bool // this tile is me
		var isMine: Bool // authUser is checking the user
		var isFollowingUser: Bool?
		public init(profileUserId: String, authUserId: String, user: User, follower: Bool) {
			self.profileUserId = profileUserId
			self.authUserId = authUserId
			self.user = user
			self.follower = follower

			self.isMe = authUserId == user.id
			self.isMine = authUserId == profileUserId
		}
		public var id: String {
			user.id
		}
	}
	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case task
		case subscriptions
		case onTapFollowingButton
		case onToggleFollowAction
		case isFollowingUserResponse(Bool)
		case delegate(Delegate)
		public enum Delegate {
			case onRemoveFollowerAction
		}
	}
	
	@Dependency(\.userClient.databaseClient) var databaseClient
	
	private enum Cancel: Hashable {
		case isFollowingUser
	}
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .task:
				return .run { [authUserId = state.authUserId, userId = state.user.id, isFollower = state.follower] send in
					await withTaskGroup(of: Void.self) { group in
						group.addTask {
							await subscribeIsFollowingUser(send: send, userId: userId, authUserId: authUserId)
						}
					}
				}
			case .subscriptions:
				return .none
			case .onTapFollowingButton:
				return .run { [userId = state.user.id, authUserId = state.authUserId] send in
					try await databaseClient.follow(userId, authUserId)
				}
			case .onToggleFollowAction:
				return .run { [userId = state.user.id] send in
					try await databaseClient.follow(userId, nil)
				}
			case .delegate:
				return .none
			case let .isFollowingUserResponse(isFollowingUser):
				state.isFollowingUser = isFollowingUser
				return .none
			}
		}
	}
	
	private func subscribeIsFollowingUser(send: Send<Action>, userId: String, authUserId: String) async {
		await withTaskCancellation(id: Cancel.isFollowingUser, cancelInFlight: true) {
			for await isFollowingUser in await databaseClient.followingStatus(userId, authUserId) {
				await send(.isFollowingUserResponse(isFollowingUser), animation: .snappy)
			}
		}
	}
}

public struct UserProfileListTileView: View {
	@Bindable var store: StoreOf<UserProfileListTileReducer>
	@Environment(\.textTheme) var textTheme
	public init(store: StoreOf<UserProfileListTileReducer>) {
		self.store = store
	}
	public var body: some View {
		HStack {
			UserProfileAvatar(
				userId: store.user.id,
				avatarUrl: store.user.avatarUrl,
				radius: 23
			)
			HStack(spacing: AppSpacing.md) {
				VStack(alignment: .leading) {
					HStack {
						Text(store.user.displayUsername)
							.font(textTheme.titleLarge.font)
							.foregroundStyle(Assets.Colors.bodyColor)
						if let isFollowingUser = store.isFollowingUser {
							followTextButton(isFollowingUser: isFollowingUser)
								.layoutPriority(1)
						}
					}
					Text(store.user.displayFullName)
						.font(textTheme.labelLarge.font)
						.fontWeight(.semibold)
						.foregroundStyle(Assets.Colors.gray)
				}
				.lineLimit(1)
				Spacer()
				if let isFollowingUser = store.isFollowingUser {
					if !(store.isMe && !store.isMine) {
						UserActionButton(
							user: store.user,
							isMe: store.isMe,
							isMine: store.isMine,
							follower: store.follower,
							isFollowingUser: isFollowingUser,
							action: {
								if store.follower {
									if store.isMine {
										store.send(.delegate(.onRemoveFollowerAction))
									} else {
										store.send(.onToggleFollowAction)
									}
								} else {
									store.send(.onToggleFollowAction)
								}
							}
						)
						.frame(width: 120, height: 36)
					}
				}
				if store.isMine && store.follower {
					Button {
						store.send(.delegate(.onRemoveFollowerAction))
					} label: {
						Image(systemName: "ellipsis")
							.rotationEffect(.degrees(90))
					}
					.fadeEffect()
				}
			}
			Spacer()
		}
		.task {
			await store.send(.task).finish()
		}
	}
	
	@ViewBuilder
	private func followTextButton(isFollowingUser: Bool) -> some View {
		if store.follower && store.isMine {
			Text(" • ")
				.font(textTheme.bodyMedium.font)
				.foregroundStyle(Assets.Colors.bodyColor)
			Button {
				store.send(.onTapFollowingButton)
			} label: {
				Text(isFollowingUser ? "Followed" : "Follow")
					.font(textTheme.bodyMedium.font)
					.foregroundStyle(isFollowingUser ? Assets.Colors.gray : Assets.Colors.blue)
			}
			.buttonStyle(.plain)
		}
	}
}

private struct UserActionButton: View {
	let user: User
	let isMe: Bool
	let isMine: Bool
	let follower: Bool
	let isFollowingUser: Bool
	let action: () -> Void
	init(user: User, isMe: Bool, isMine: Bool, follower: Bool, isFollowingUser: Bool, action: @escaping () -> Void) {
		self.user = user
		self.isMe = isMe
		self.isMine = isMine
		self.follower = follower
		self.isFollowingUser = isFollowingUser
		self.action = action
	}
	@Environment(\.textTheme) var textTheme
	@Environment(\.colorScheme) var colorScheme
	var body: some View {
		composedBody()
	}
	
	@ViewBuilder
	private func removeFollowerButton() -> some View {
		UserProfileButton<EmptyView>(
			label: "Remove",
			action: action
		)
	}
	
	@ViewBuilder
	private func followingButton() -> some View {
		UserProfileButton<EmptyView>(
			label: isFollowingUser ? "Following" : "Follow",
			color: isFollowingUser ? nil : Assets.Colors.customReversedAdaptiveColor(colorScheme, light: Assets.Colors.lightBlue, dark: Assets.Colors.blue),
			action: action
		)
		.foregroundStyle(isFollowingUser ? Assets.Colors.bodyColor : Assets.Colors.white)
	}
	
	@ViewBuilder
	private func composedBody() -> some View {
		switch (follower, isMine, isMe) {
		case (true, true, false): removeFollowerButton()
		case (true, false, false): followingButton()
		case (false, true, false): followingButton()
		case (false, false, false): followingButton()
		default: EmptyView()
		}
	}
}
