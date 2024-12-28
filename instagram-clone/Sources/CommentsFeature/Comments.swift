import AppUI
import ComposableArchitecture
import Foundation
import InstaBlocks
import InstagramClient
import Shared
import SwiftUI

@Reducer
public struct CommentsReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var post: InstaBlockWrapper
		var currentUserId: String
		var comments: IdentifiedArrayOf<CommentReducer.State> = []
		var commentInput: CommentTextInputReducer.State
		var commentEmojis = ["🩷", "🙌", "🔥", "👏🏻", "😢", "😍", "😮", "😂"]
		var repliedTo: Comment?
		public init(post: InstaBlockWrapper, currentUserId: String) {
			self.post = post
			self.currentUserId = currentUserId
			self.commentInput = CommentTextInputReducer.State(userId: currentUserId)
		}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case comments(IdentifiedActionOf<CommentReducer>)
		case commentsUpdate([Comment])
		case commentInput(CommentTextInputReducer.Action)
		case onTapEmoji(String)
		case onTapDeleteRepliedToCommentButton
		case clearRepliedToComment
		case task
	}
	
	@Dependency(\.instagramClient.databaseClient) var databaseClient
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Scope(state: \.commentInput, action: \.commentInput) {
			CommentTextInputReducer()
		}
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case let .comments(.element(_, subAction)):
				switch subAction {
				case let .userComment(.delegate(.onTapReplyButton(comment))):
					state.repliedTo = comment
					return .none
				case let .repliedComments(.delegate(.onTapCommentReply(comment))):
					state.repliedTo = comment
					return .none
				default: return .none
				}
			case .comments:
				return .none
			case .task:
				return .run { [postId = state.post.id] send in
					for await comments in await databaseClient.commentsOf(postId) {
						await send(.commentsUpdate(comments), animation: .snappy)
					}
				}
			case let .commentsUpdate(comments):
				for comment in comments {
					if state.comments[id: comment.id] == nil {
						state.comments.append(CommentReducer.State(comment: comment, currentUserId: state.currentUserId, post: state.post))
					}
				}
				var removeCommentIds: [String] = []
				let commentIds = comments.map(\.id)
				for commentId in state.comments.ids {
					if !commentIds.contains(commentId) {
						removeCommentIds.append(commentId)
					}
				}
				state.comments.removeAll(where: { removeCommentIds.contains($0.id) })
				return .none
			case let .commentInput(.delegate(.onTapPublishCommentButton(content))):
				return .run { [repliedToComment = state.repliedTo, postId = state.post.id, userId = state.currentUserId] send in
					var repliedToCommentId: String?
					if let repliedToComment {
						repliedToCommentId = repliedToComment.isReplied ? repliedToComment.repliedToCommentId! : repliedToComment.id
					}
					try await databaseClient.createComment(postId, userId, content, repliedToCommentId)
					await send(.clearRepliedToComment, animation: .easeInOut)
				}
			case .commentInput:
				return .none
			case let .onTapEmoji(emoji):
				return .send(.commentInput(.appendCommentInput(emoji)))
			case .onTapDeleteRepliedToCommentButton:
				state.repliedTo = nil
				return .none
			case .clearRepliedToComment:
				state.repliedTo = nil
				return .none
			}
		}
		.forEach(\.comments, action: \.comments) {
			CommentReducer()
		}
	}
}

public struct CommentsView: View {
	@Bindable var store: StoreOf<CommentsReducer>
	@Environment(\.textTheme) var textTheme
	@Environment(\.colorScheme) var colorScheme
	public init(store: StoreOf<CommentsReducer>) {
		self.store = store
	}

	public var body: some View {
		commentsList()
			.safeAreaInset(edge: .bottom) {
				bottomBar()
			}
			.task {
				await store.send(.task).finish()
			}
	}
	
	@ViewBuilder
	private func commentsList() -> some View {
		ScrollView(.vertical) {
			
			Text("Comments")
				.font(textTheme.titleLarge.font)
				.bold()
				.foregroundStyle(Assets.Colors.gray)
				.frame(maxWidth: .infinity, alignment: .center)
				.padding(.top, 40)
			if !store.comments.isEmpty {
				LazyVStack {
					ForEach(store.scope(state: \.comments, action: \.comments)) { commentStore in
						CommentView(store: commentStore)
					}
				}
				.padding(.horizontal)
			}
		}
		.scrollDismissesKeyboard(.immediately)
		.scrollIndicators(.hidden)
		.overlay(alignment: .center) {
			if store.comments.isEmpty {
				Text("No Comments")
					.font(textTheme.headlineLarge.font)
					.bold()
					.foregroundStyle(Assets.Colors.bodyColor)
					.frame(maxWidth: .infinity, alignment: .center)
			}
		}
	}
	
	@ViewBuilder
	private func commentEmojis() -> some View {
		HStack(spacing: AppSpacing.xlg) {
			ForEach(store.commentEmojis, id: \.self) { emoji in
				Button {
					store.send(.onTapEmoji(emoji))
				} label: {
					Text(emoji)
						.font(textTheme.headlineMedium.font)
						.contentShape(.rect)
				}
				.scaleEffect(config: ButtonAnimationConfig(scale: .lg))
				.fixedSize()
			}
		}
		
		.frame(maxWidth: .infinity)
	}
	
	@ViewBuilder
	private func bottomBar() -> some View {
		VStack {
			if let repliedToComment = store.repliedTo {
				repliedToCommentView(repliedToComment: repliedToComment)
					.transition(.move(edge: .bottom).combined(with: .opacity))
			}
			commentEmojis()
				.padding()
			CommentTextInputView(store: store.scope(state: \.commentInput, action: \.commentInput))
				.padding()
		}
		
		.background(
			Assets.Colors.bottomSheetModalBackgroundColor
		)
		.frame(maxWidth: .infinity)
	}
	
	@ViewBuilder
	private func repliedToCommentView(repliedToComment: Comment) -> some View {
		Assets.Colors.customReversedAdaptiveColor(
			colorScheme,
			light: Assets.Colors.brightGray,
			dark: Assets.Colors.background
		)
		.overlay {
			HStack {
				Text("Reply to \(repliedToComment.author.username)")
				Spacer()
				Button {
					store.send(.onTapDeleteRepliedToCommentButton, animation: .easeInOut)
				} label: {
					Image(systemName: "xmark.circle")
						.imageScale(.large)
				}
			}
			.font(textTheme.bodyMedium.font)
			.foregroundStyle(Assets.Colors.gray)
			.padding(.horizontal)
		}
		.frame(maxWidth: .infinity)
		.frame(height: 40)
	}
}
