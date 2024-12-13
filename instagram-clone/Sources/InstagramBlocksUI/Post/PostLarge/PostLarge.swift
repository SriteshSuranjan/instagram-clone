import AppUI
import ComposableArchitecture
import Foundation
import InstaBlocks
import Shared
import SwiftUI

/* final PostBlock block;
 final bool isOwner;
 final bool isFollowed;
 final VoidCallback follow;
 final bool isLiked;
 final VoidCallback likePost;
 final int likesCount;
 final int commentsCount;
 final bool enableFollowButton;
 final BlockActionCallback onPressed;
 final ValueSetter<bool> onCommentsTap;
 final OnPostShareTap onPostShareTap;
 final ValueSetter<String> onUserTap;
 final PostOptionsSettings postOptionsSettings;
 final AvatarBuilder? postAuthorAvatarBuilder;
 final VideoPlayerBuilder? videoPlayerBuilder;
 final int? postIndex;
 final bool withInViewNotifier;
 final LikesCountBuilder? likesCountBuilder;
 final List<User>? likersInFollowings; */

@Reducer
public struct PostLargeReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var block: InstaBlockWrapper
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
			likersInFollowings: [User]? = nil
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
			self.header = PostHeaderReducer.State(
				block: block,
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
				isLiked: isLiked,
				likesCount: likesCount,
				commentsCount: commentCount,
				mediaUrls: block.mediaUrls,
//				likersInFollowings: [
//					User(
//					id: "11",
//					email: nil,
//					username: nil,
//					fullName: nil,
//					avatarUrl: "https://uuhkqhxfbjovbighyxab.supabase.co/storage/v1/object/sign/avatars/2024-12-09T13:17:05Z.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJhdmF0YXJzLzIwMjQtMTItMDlUMTM6MTc6MDVaLnBuZyIsImlhdCI6MTczMzc1MDIzMCwiZXhwIjoxNzMzNzUwMjkwfQ.dQPRTi88KIssjIyJgennCbkQOwjJePionj-Fza8Z4K8",
//					pushToken: nil,
//					isNewUser: false
//				),
//					User(id: "22", avatarUrl: "https://uuhkqhxfbjovbighyxab.supabase.co/storage/v1/object/sign/avatars/2024-12-09T15:44:00.078471.jpg?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJhdmF0YXJzLzIwMjQtMTItMDlUMTU6NDQ6MDAuMDc4NDcxLmpwZyIsImlhdCI6MTczMzczMDI0MywiZXhwIjoyMDQ5MDkwMjQzfQ.hukTLDivWUBKKEpukDmJ1H1qcaa87pgZnmLqRmnrvI0")],
				likersInFollowings: [],
				currentMediaIndex: self._currentMediaIndex
			)
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
	}
}

public struct PostLargeView<Avatar: View, LikesCount: View>: View {
	@Bindable var store: StoreOf<PostLargeReducer>
	let postOptionsSettings: PostOptionsSettings
//	let likePost: () -> Void
//	let blockActionCallback: (any PostBlock) -> Void
//	let onCommentsTap: (Bool) -> Void
//	let onPostShareTap: (_ postId: String, _ author: PostAuthor) -> Void
	@ViewBuilder let postAuthorAvatarBuilder: ((PostAuthor, ((String?) -> Void)?) -> Avatar)?
	@ViewBuilder let likesCountBuilder: (_ name: String?, _ userId: String?, _ count: Int) -> LikesCount
	public init(
		store: StoreOf<PostLargeReducer>,
		postOptionsSettings: PostOptionsSettings,
//		likePost: @escaping () -> Void,
//		blockActionCallback: @escaping (any PostBlock) -> Void,
//		onCommentsTap: @escaping (Bool) -> Void,
//		onPostShareTap: @escaping (_: String, _: PostAuthor) -> Void,
		postAuthorAvatarBuilder: ((PostAuthor, ((String?) -> Void)?) -> Avatar)?,
		likesCountBuilder: @escaping (_: String?, _: String?, _: Int) -> LikesCount
	) {
		self.store = store
		self.postOptionsSettings = postOptionsSettings
//		self.likePost = likePost
//		self.blockActionCallback = blockActionCallback
//		self.onCommentsTap = onCommentsTap
//		self.onPostShareTap = onPostShareTap
		self.postAuthorAvatarBuilder = postAuthorAvatarBuilder
		self.likesCountBuilder = likesCountBuilder
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
			color: nil,
			postAuthorAvatarBuilder: postAuthorAvatarBuilder
		)
	}
	
	@ViewBuilder
	private func postFooter() -> some View {
		PostFooterView(store: store.scope(state: \.footer, action: \.footer))
	}
}

#Preview {
	List {
		PostLargeView<EmptyView, EmptyView>(
			store: Store(
				initialState: PostLargeReducer.State(
					block: .postLarge(
						PostLargeBlock(
							id: "aaf841ab-e823-4187-8a07-f9bfdc98e0a4",
							author: PostAuthor(),
							createdAt: Date.now,
							caption: "This is caption",
							media: [
								.image(ImageMedia(id: "123445", url: "https://uuhkqhxfbjovbighyxab.supabase.co/storage/v1/object/public/posts/079b8318-51bc-4b50-80ac-fbf42361124d/image_0", blurHash: "LVC?N0af9+bJ0ga{-ijX=@e-N2az")),
								.video(
									VideoMedia(
										id: "d7784ce7-49ca-461a-ab52-14017f9be458",
										url: "https://uuhkqhxfbjovbighyxab.supabase.co/storage/v1/object/public/posts/00c8e0ea-d59e-45ee-b0d6-5034ff2d61e2/video_0",
										blurHash: "LQKT[CR*?v-p~Vx^V@jb?aInRPWX",
										firstFrameUrl: "https://uuhkqhxfbjovbighyxab.supabase.co/storage/v1/object/public/posts/00c8e0ea-d59e-45ee-b0d6-5034ff2d61e2/video_first_frame_0)"
									)
								)
							]
						)
					),
					isOwner: true,
					isFollowed: false,
					isLiked: true,
					likesCount: 10,
					commentCount: 10,
					enableFollowButton: true,
					withInViewNotifier: false
				),
				reducer: { PostLargeReducer() }
			),
			postOptionsSettings: .viewer,
			postAuthorAvatarBuilder: nil,
			likesCountBuilder: { _, _, _ in EmptyView() }
		)
		PostLargeView<EmptyView, EmptyView>(
			store: Store(
				initialState: PostLargeReducer.State(
					block: .postSponsored(
						PostSponsoredBlock(
							author: PostAuthor(),
							id: "aaf851ab-e823-4187-8a07-f9bfdc98e0a4",
							createdAt: Date.now,
							media: [
								.image(ImageMedia(id: "123445", url: "https://uuhkqhxfbjovbighyxab.supabase.co/storage/v1/object/public/posts/079b8318-51bc-4b50-80ac-fbf42361124d/image_0", blurHash: "LVC?N0af9+bJ0ga{-ijX=@e-N2az")),
								.video(
									VideoMedia(
										id: "d7784ce7-49ca-461a-ab52-14017f9be458",
										url: "https://uuhkqhxfbjovbighyxab.supabase.co/storage/v1/object/public/posts/00c8e0ea-d59e-45ee-b0d6-5034ff2d61e2/video_0",
										blurHash: "LQKT[CR*?v-p~Vx^V@jb?aInRPWX",
										firstFrameUrl: "https://uuhkqhxfbjovbighyxab.supabase.co/storage/v1/object/public/posts/00c8e0ea-d59e-45ee-b0d6-5034ff2d61e2/video_first_frame_0)"
									)
								)
							],
							caption: "This is caption",
							isSponsored: true
						)
					),
					isOwner: true,
					isFollowed: false,
					isLiked: true,
					likesCount: 10,
					commentCount: 10,
					enableFollowButton: true,
					withInViewNotifier: false
				),
				reducer: { PostLargeReducer() }
			),
			postOptionsSettings: .viewer,
			postAuthorAvatarBuilder: nil,
			likesCountBuilder: { _, _, _ in EmptyView() }
		)
		.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
	}
	.listStyle(.plain)
}
