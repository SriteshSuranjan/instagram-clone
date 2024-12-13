import Foundation
import SwiftUI
import ComposableArchitecture
import AppUI
import InstaBlocks
import Shared

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
			ForEach(store.feeds) { feed in
				AsyncImage(url: URL(string: feed.media?.first?.url ?? "")) { image in
					image
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(maxWidth: .infinity)
						.clipped()
				} placeholder: {
					ProgressView()
				}

			}
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
