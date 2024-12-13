import AppUI
import ComposableArchitecture
import Foundation
import InstaBlocks
import Shared
import SwiftUI

@Reducer
public struct PostHeaderReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var block: InstaBlockWrapper
		var isOwner: Bool
		var isFollowed: Bool
		var enableFollowButton: Bool
		var isSponsored: Bool
		public init(
			block: InstaBlockWrapper,
			isOwner: Bool,
			isFollowed: Bool,
			enableFollowButton: Bool,
			isSponsored: Bool
		) {
			self.block = block
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

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
	}

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { _, action in
			switch action {
			case .binding:
				return .none
			}
		}
	}
}

public struct PostHeaderView<Avatar: View>: View {
	@Bindable var store: StoreOf<PostHeaderReducer>
	let onTapAvatar: ((String?) -> Void)?
	let follow: () -> Void
	let postAuthorAvatarBuilder: ((PostAuthor, ((String?) -> Void)?) -> Avatar)?
	let color: Color?
	@Environment(\.textTheme) var textTheme
	public init(
		store: StoreOf<PostHeaderReducer>,
		onTapAvatar: ((String?) -> Void)?,
		follow: @escaping () -> Void,
		color: Color?,
		postAuthorAvatarBuilder: ((PostAuthor, ((String?) -> Void)?) -> Avatar)?
	) {
		self.store = store
		self.onTapAvatar = onTapAvatar
		self.follow = follow
		self.color = color
		self.postAuthorAvatarBuilder = postAuthorAvatarBuilder
	}

	public var body: some View {
		HStack(spacing: AppSpacing.md) {
			if let postAuthorAvatarBuilder {
				postAuthorAvatarBuilder(store.block.author, onTapAvatar)
			} else {
				UserProfileAvatar(
					userId: store.block.author.id,
					avatarUrl: store.block.author.avatarUrl,
					isLarge: false,
					animationConfig: ButtonAnimationConfig(),
					onTap: onTapAvatar
				)
			}
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
		.padding(.vertical, AppSpacing.sm)
		.padding(.horizontal, AppSpacing.sm)
	}
}


#Preview {
	Group {
		PostHeaderView<EmptyView>(
			store: Store(
				initialState: PostHeaderReducer.State(
					block: .postSponsored(
						PostSponsoredBlock(
							author: PostAuthor(),
							id: "371278938712",
							createdAt: Date(),
							media: [.image(ImageMedia(id: "1772378", url: "https://images.unsplash.com/photo-1719937050679-c3a2c9c67b0f?q=80&w=3544&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", blurHash: nil))],
							caption: "This is preview post",
							isSponsored: true
						)
					),
					isOwner: false,
					isFollowed: false,
					enableFollowButton: false,
					isSponsored: true
				),
				reducer: { PostHeaderReducer() }
			),
			onTapAvatar: nil,
			follow: {},
			color: Assets.Colors.blue,
			postAuthorAvatarBuilder: nil
		)
		
		PostHeaderView<EmptyView>(
			store: Store(
				initialState: PostHeaderReducer.State(
					block: .postLarge(
						PostLargeBlock(
							id: "371278938712",
							author: PostAuthor(),
							createdAt: Date(),
							caption: "This is preview post",
							media: [.image(ImageMedia(id: "1772378", url: "https://images.unsplash.com/photo-1719937050679-c3a2c9c67b0f?q=80&w=3544&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", blurHash: nil))],
							isSponsored: false
						)
					),
					isOwner: false,
					isFollowed: false,
					enableFollowButton: true,
					isSponsored: false
				),
				reducer: { PostHeaderReducer() }
			),
			onTapAvatar: nil,
			follow: {},
			color: nil,
			postAuthorAvatarBuilder: nil
		)
	}
}
