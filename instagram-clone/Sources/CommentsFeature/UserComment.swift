import AppUI
import ComposableArchitecture
import Foundation
import InstaBlocks
import InstagramBlocksUI
import InstagramClient
import Shared
import SwiftUI

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
		case delegate(Delegate)
		public enum Delegate {
			case onTapReplyButton(Comment)
		}
	}

	@Dependency(\.instagramClient.databaseClient) var databaseClient

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .onTapLikeComment:
				return .run { [commentId = state.comment.id] send in
					try await databaseClient.likePost(commentId, false)
				}
			case .onTapAvatar:
				return .none
			case .onTapReplyButton:
				return .send(.delegate(.onTapReplyButton(state.comment)), animation: .easeInOut)
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
			case .delegate:
				return .none
			}
		}
	}

	private func subscriptions(send: Send<Action>, comment: Comment, post: InstaBlockWrapper) async {
		async let commentsLikesSubscription: Void = {
			for await likes in await databaseClient.likesOfPost(comment.id, false) {
				await send(.likesCountUpdate(likes))
			}
		}()
		async let isLikedSubscription: Void = {
			for await isLiked in await databaseClient.isLiked(comment.id, nil, false) {
				await send(.isLikedUpdate(isLiked))
			}
		}()
		async let isLikedByOwnerSubscription: Void = {
			for await isLikedByOwner in await databaseClient.isLiked(comment.id, post.author.id, false) {
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
			VStack(alignment: .leading, spacing: AppSpacing.sm) {
				HStack {
					Text(store.comment.author.username)
						.font(textTheme.titleSmall.font)
						.bold()
						.foregroundStyle(Assets.Colors.bodyColor)
					Text("\(timeAgo(from: store.comment.createdAt))")
						.font(textTheme.bodyLarge.font)
						.foregroundStyle(Assets.Colors.gray)
					// TODO: isLikedByOwner
				}
				Text(store.comment.content)
					.font(textTheme.titleSmall.font)
				Button("Reply") {
					store.send(.onTapReplyButton)
				}
				.font(textTheme.bodyLarge.font)
				.foregroundStyle(Assets.Colors.gray)
				.buttonStyle(.plain)
			}
			Spacer()
			Button {
				store.send(.onTapLikeComment)
			} label: {
				VStack(spacing: 4) {
					Image(systemName: store.isLiked ? "heart.fill" : "heart")
						.imageScale(.large)
						.foregroundStyle(store.isLiked ? Assets.Colors.red : Assets.Colors.gray)
					Text("\(store.likesCount)")
						.foregroundStyle(Assets.Colors.gray)
				}
				.font(textTheme.titleMedium.font)
				.contentShape(.rect)
			}
			.fadeEffect()
			
		}
		.padding(.vertical, AppSpacing.sm)
		.task {
			await store.send(.task).finish()
		}
	}
}
