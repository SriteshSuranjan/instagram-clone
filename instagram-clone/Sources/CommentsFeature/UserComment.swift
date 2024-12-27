import AppUI
import ComposableArchitecture
import Foundation
import InstaBlocks
import InstagramBlocksUI
import Shared
import SwiftUI
import InstagramClient

@Reducer
public struct UserCommentReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var comment: Comment
		var currentUserId: String
		var post: InstaBlockWrapper
		var isReplied: Bool
		var isLiked: Bool
		var isLikedByOwner: Bool
		var likesCount: Int
		public init(
			comment: Comment,
			currentUserId: String,
			post: InstaBlockWrapper,
			isReplied: Bool,
			isLiked: Bool,
			isLikedByOwner: Bool,
			likesCount: Int
		) {
			self.comment = comment
			self.currentUserId = currentUserId
			self.post = post
			self.isReplied = isReplied
			self.isLiked = isLiked
			self.isLikedByOwner = isLikedByOwner
			self.likesCount = likesCount
		}

		var canDeleteComment: Bool {
			post.author.id == currentUserId ||
				comment.author.id == currentUserId
		}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case likesCountUpdate(Int)
		case isLikedUpdate(Bool)
		case isLikedByOwnerUpdate(Bool)
		case onTapLikeComment
		case onTapAvatar
		case onTapReplyButton
		case onLongPressed
		case task
	}
	
	@Dependency(\.instagramClient.databaseClient) var databaseClient

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .onTapLikeComment:
				return .none
			case .onTapAvatar:
				return .none
			case .onTapReplyButton:
				return .none
			case .onLongPressed:
				return .none
			case let .likesCountUpdate(likesCount):
				state.likesCount = likesCount
				return .none
			case let .isLikedUpdate(isLiked):
				state.isLiked = isLiked
				return .none
			case let .isLikedByOwnerUpdate(isLikedByOwner):
				state.isLikedByOwner = isLikedByOwner
				return .none
			case .task:
				return .run { [comment = state.comment, post = state.post] send in
					await subscriptions(send: send, comment: comment, post: post)
				}
			}
		}
	}
	
	private func subscriptions(send: Send<Action>, comment: Comment, post: InstaBlockWrapper) async {
		async let commentsLikesSubscription: Void = {
			for await likes in await databaseClient.likesOfPost(post.id, false) {
				await send(.likesCountUpdate(likes))
			}
		}()
		async let isLikedSubscription: Void = {
			for await isLiked in await databaseClient.isLiked(post.id, nil, false) {
				await send(.isLikedUpdate(isLiked))
			}
		}()
		async let isLikedByOwnerSubscription: Void = {
			for await isLikedByOwner in await databaseClient.isLiked(post.id, post.author.id, false) {
				await send(.isLikedByOwnerUpdate(isLikedByOwner))
			}
		}()
		
		_ = await (commentsLikesSubscription, isLikedSubscription, isLikedByOwnerSubscription)
	}
}

public struct UserCommentView: View {
	let store: StoreOf<UserCommentReducer>
	@Environment(\.textTheme) var textTheme
	@Environment(\.colorScheme) var colorScheme
	public init(store: StoreOf<UserCommentReducer>) {
		self.store = store
	}

	public var body: some View {
		HStack {
			UserProfileAvatar(
				userId: store.comment.author.id,
				avatarUrl: store.comment.author.avatarUrl,
				radius: store.isReplied ? AppSize.iconSizeXSmall : AppSize.iconSizeSmall
			)
			VStack(alignment: .leading, spacing: AppSpacing.xs) {
				HStack {
					Text(store.comment.author.username)
						.font(textTheme.labelLarge.font)
						.bold()
						.foregroundStyle(Assets.Colors.bodyColor)
					Text("\(timeAgo(from: store.comment.createdAt))")
						.font(textTheme.bodyMedium.font)
						.foregroundStyle(Assets.Colors.gray)
					// TODO: isLikedByOwner
				}
				Text(store.comment.content)
					.font(textTheme.bodySmall.font)
				Button("Reply") {}
					.font(textTheme.labelLarge.font)
					.foregroundStyle(Assets.Colors.gray)
					.buttonStyle(.plain)
			}
			Spacer()
			// TODO: Like Button
			VStack(spacing: 4) {
				Image(systemName: store.isLiked ? "heart.fill" : "heart")
					.imageScale(.large)
					.foregroundStyle(store.isLiked ? Assets.Colors.red : Assets.Colors.gray)
				Text("\(store.likesCount)")
					.foregroundStyle(Assets.Colors.gray)
			}
			.font(textTheme.titleMedium.font)
		}
		.task {
			await store.send(.task).finish()
		}
	}
}
