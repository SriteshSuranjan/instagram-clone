import AppUI
import ComposableArchitecture
import Foundation
import InstaBlocks
import Shared
import SwiftUI

@Reducer
public struct PostLargeReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable, Identifiable {
		public private(set) var block: InstaBlockWrapper
		var isOwner: Bool
		var isFollowed: Bool
		var isLiked: Bool
		var likesCount: Int
		var commentCount: Int
		var enableFollowButton: Bool
		var postIndex: Int?
		var withInViewNotifier: Bool
		var likersInFollowings: [User]?
		@Shared var currentMediaIndex: Int
		var profileUserId: String
		var header: PostHeaderReducer.State
		var media: PostMediaReducer.State
		var footer: PostFooterReducer.State
		public init(
			block: InstaBlockWrapper,
			isOwner: Bool,
			isFollowed: Bool,
			isLiked: Bool,
			likesCount: Int,
			commentCount: Int,
			enableFollowButton: Bool,
			postIndex: Int? = nil,
			withInViewNotifier: Bool,
			likersInFollowings: [User]? = nil,
			profileUserId: String
		) {
			self.block = block
			self.isOwner = isOwner
			self.isFollowed = isFollowed
			self.isLiked = isLiked
			self.likesCount = likesCount
			self.commentCount = commentCount
			self.enableFollowButton = enableFollowButton
			self.postIndex = postIndex
			self.withInViewNotifier = withInViewNotifier
			self.likersInFollowings = likersInFollowings
			self._currentMediaIndex = Shared(0)
			self.profileUserId = profileUserId
			self.header = PostHeaderReducer.State(
				block: block,
				profileUserId: profileUserId,
				isOwner: isOwner,
				isFollowed: isFollowed,
				enableFollowButton: enableFollowButton,
				isSponsored: block.isSponsored
			)
			self.media = PostMediaReducer.State(
				media: block.media ?? [],
				postIndex: 0,
				isLiked: true,
				currentMediaIndex: self._currentMediaIndex
			)
			self.footer = PostFooterReducer.State(
				block: block,
				profileUserId: profileUserId,
				isLiked: isLiked,
				likesCount: likesCount,
				commentsCount: commentCount,
				mediaUrls: block.mediaUrls,
				likersInFollowings: [],
				currentMediaIndex: self._currentMediaIndex
			)
		}
		public var id: String {
			block.id
		}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case header(PostHeaderReducer.Action)
		case media(PostMediaReducer.Action)
		case footer(PostFooterReducer.Action)
	}

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Scope(state: \.header, action: \.header) {
			PostHeaderReducer()
		}
		Scope(state: \.media, action: \.media) {
			PostMediaReducer()
		}
		Scope(state: \.footer, action: \.footer) {
			PostFooterReducer()
		}
		Reduce { _, action in
			switch action {
			case .binding:
				return .none
			case .header:
				return .none
			case .media:
				return .none
			case .footer:
				return .none
			}
		}
		._printChanges()
	}
}

public struct PostLargeView: View {
	@Bindable var store: StoreOf<PostLargeReducer>
	let postOptionsSettings: PostOptionsSettings
//	let likePost: () -> Void
//	let blockActionCallback: (any PostBlock) -> Void
//	let onCommentsTap: (Bool) -> Void
//	let onPostShareTap: (_ postId: String, _ author: PostAuthor) -> Void
//	@ViewBuilder let postAuthorAvatarBuilder: ((PostAuthor, ((String?) -> Void)?) -> Avatar)?
//	@ViewBuilder let likesCountBuilder: (_ name: String?, _ userId: String?, _ count: Int) -> LikesCount
	public init(
		store: StoreOf<PostLargeReducer>,
		postOptionsSettings: PostOptionsSettings
//		likePost: @escaping () -> Void,
//		blockActionCallback: @escaping (any PostBlock) -> Void,
//		onCommentsTap: @escaping (Bool) -> Void,
//		onPostShareTap: @escaping (_: String, _: PostAuthor) -> Void
	) {
		self.store = store
		self.postOptionsSettings = postOptionsSettings
//		self.likePost = likePost
//		self.blockActionCallback = blockActionCallback
//		self.onCommentsTap = onCommentsTap
//		self.onPostShareTap = onPostShareTap
	}

	public var body: some View {
		if store.block.isReel {
			VStack(spacing: 0) {
				postMedia()
					.overlay(alignment: .topLeading) {
						postHeader()
					}
				postFooter()
			}
		} else {
			VStack(spacing: 0) {
				postHeader()
				postMedia()
				postFooter()
			}
		}
	}

	@ViewBuilder
	private func postMedia() -> some View {
		PostMediaView(store: store.scope(state: \.media, action: \.media))
	}

	@ViewBuilder
	private func postHeader() -> some View {
		PostHeaderView(
			store: store.scope(state: \.header, action: \.header),
			onTapAvatar: nil,
			follow: {},
			color: nil
		)
	}
	
	@ViewBuilder
	private func postFooter() -> some View {
		PostFooterView(store: store.scope(state: \.footer, action: \.footer))
	}
}
