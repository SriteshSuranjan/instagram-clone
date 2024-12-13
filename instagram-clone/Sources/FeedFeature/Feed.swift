import Foundation
import SwiftUI
import ComposableArchitecture
import AppUI
import InstaBlocks
import Shared
import InstagramBlocksUI

@Reducer
public struct FeedReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var feeds: [InstaBlockWrapper]
		public init(feeds: [InstaBlockWrapper] = []) {
			self.feeds = feeds
		}
	}
	public enum Action: BindableAction {
		case binding(BindingAction<State>)
	}
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			}
		}
	}
}

public struct FeedView: View {
	@Environment(\.textTheme) var textTheme
	@Bindable var store: StoreOf<FeedReducer>
	public init(store: StoreOf<FeedReducer>) {
		self.store = store
	}
	public var body: some View {
		List {
//			ForEach(store.feeds) { feed in
//				AsyncImage(url: URL(string: feed.media?.first?.url ?? "")) { image in
//					image
//						.resizable()
//						.aspectRatio(contentMode: .fit)
//						.frame(maxWidth: .infinity)
//						.clipped()
//				} placeholder: {
//					ProgressView()
//				}
//
//			}
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
						block: .postLarge(
							PostLargeBlock(
								id: "aaf851ab-e823-4187-8a07-f9bfdc98e0a4",
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
			.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
		}
		.listStyle(.plain)
	}
}

#Preview {
	let post = PostLargeBlock(
		id: UUID().uuidString,
			author: PostAuthor(randomConfirmed: nil),
			createdAt: Date.now.addingTimeInterval(-CGFloat((0...365).randomElement()! * 24 * 3600)),
			caption: "Lorem ipsum dolor sit ",
		media: [.image(ImageMedia(id: "https://images.unsplash.com/photo-1733251744520-add362ab1ee7?q=80&w=3687&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", url: "https://images.unsplash.com/photo-1733251744520-add362ab1ee7?q=80&w=3687&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", blurHash: nil))]
		)
	
	let posts: [InstaBlockWrapper] = Array.init(repeating: .postLarge(post), count: 10)
	FeedView(
		store: Store(
			initialState: FeedReducer.State(feeds: posts),
			reducer: { FeedReducer() }
		)
	)
}
