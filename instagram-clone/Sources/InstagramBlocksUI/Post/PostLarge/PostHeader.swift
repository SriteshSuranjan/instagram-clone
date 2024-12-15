import AppUI
import ComposableArchitecture
import Foundation
import InstaBlocks
import Shared
import SwiftUI
import UserClient

@Reducer
public struct PostHeaderReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var profileUserId: String
		var block: InstaBlockWrapper
		var isOwner: Bool
		var isFollowed: Bool
		var enableFollowButton: Bool
		var isSponsored: Bool
		public init(
			block: InstaBlockWrapper,
			profileUserId: String,
			isOwner: Bool,
			isFollowed: Bool,
			enableFollowButton: Bool,
			isSponsored: Bool
		) {
			self.block = block
			self.profileUserId = profileUserId
			self.isOwner = isOwner
			self.isFollowed = isFollowed
			self.enableFollowButton = enableFollowButton
			self.isSponsored = isSponsored
		}

		var showFollowButton: Bool {
			if isSponsored {
				return false
			}
			if isOwner {
				return false
			}
			return !isFollowed
		}
	}

	@Dependency(\.userClient.databaseClient) var databaseClient

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case task
		case postAuthorFollowingStatusDidUpdated(Bool)
		case followAuthor
	}

	private enum Cancel: Hashable {
		case followingStatusSubscription
		case followRequest
	}

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none

			case .task:
				return .run { [postAuthorId = state.block.author.id, profileUserId = state.profileUserId] send in
					if postAuthorId != profileUserId {
						for await isFollowed in await databaseClient.postAuthorFollowingStatus(postAuthorId, profileUserId) {
							await send(.postAuthorFollowingStatusDidUpdated(isFollowed))
						}
					}
				}.cancellable(id: Cancel.followingStatusSubscription, cancelInFlight: true)
			case .postAuthorFollowingStatusDidUpdated(let isFollowed):
				state.isFollowed = isFollowed
				debugPrint("isFollowed: \(isFollowed)")
				return .none
			case .followAuthor:
				return .run { [postAuthorId = state.block.author.id, profileUserId = state.profileUserId] _ in
					try await databaseClient.follow(postAuthorId, profileUserId)
				}
				.cancellable(id: Cancel.followRequest, cancelInFlight: true)
			}
		}
	}
}

public struct PostHeaderView: View {
	@Bindable var store: StoreOf<PostHeaderReducer>
	let onTapAvatar: ((String) -> Void)?
	let follow: () -> Void
	let color: Color?
	@Environment(\.textTheme) var textTheme
	public init(
		store: StoreOf<PostHeaderReducer>,
		onTapAvatar: ((String) -> Void)?,
		follow: @escaping () -> Void,
		color: Color?
	) {
		self.store = store
		self.onTapAvatar = onTapAvatar
		self.follow = follow
		self.color = color
	}

	public var body: some View {
		HStack(spacing: AppSpacing.md) {
			UserProfileAvatar(
				userId: store.block.author.id,
				avatarUrl: store.block.author.avatarUrl,
				isLarge: false,
				animationConfig: ButtonAnimationConfig(),
				onTap: { _ in
					onTapAvatar?(store.block.author.id)
				}
			)
			VStack(alignment: .leading, spacing: AppSpacing.xxs) {
				HStack(spacing: AppSpacing.sm) {
					Text(store.block.author.username)
						.font(textTheme.titleMedium.font)
						.foregroundStyle(color ?? Assets.Colors.bodyColor)
					if store.isSponsored {
						Assets.Icons.verifiedUser
							.view(width: AppSize.iconSizeSmall, height: AppSize.iconSizeSmall, renderMode: .original)
					}
				}
				if store.isSponsored {
					Text("Sponsored")
						.font(textTheme.bodyMedium.font)
						.foregroundStyle(color ?? Assets.Colors.bodyColor)
				}
			}

			Spacer()
			if store.showFollowButton && store.enableFollowButton {
				HStack(spacing: AppSpacing.md) {
					FollowButton(
						isFollowed: store.isFollowed,
						isOutlined: color != nil
					) {
						store.send(.followAuthor)
					}
					Button {} label: {
						Image(systemName: "ellipsis")
							.rotationEffect(.degrees(90))
							.contentShape(.rect)
					}
					.fadeEffect()
				}
			}
		}
		.padding(.horizontal, AppSpacing.sm)
		.padding(.vertical, AppSpacing.sm)
		.task {
			await store.send(.task).finish()
		}
	}
}
