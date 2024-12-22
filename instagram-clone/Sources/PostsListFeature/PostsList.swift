import Foundation
import SwiftUI
import ComposableArchitecture
import AppUI
import InstagramBlocksUI
import InstagramClient
import InstaBlocks

@Reducer
public struct PostsListReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var blocks: [InstaBlockWrapper]
		var scrollTo: String?
		var profileUserId: String
		var posts: IdentifiedArrayOf<PostLargeReducer.State>
		public init(
			blocks: [InstaBlockWrapper] = [],
			scrollTo: String? = nil,
			profileUserId: String
		) {
			self.blocks = blocks
			self.scrollTo = scrollTo
			self.profileUserId = profileUserId
			self.posts = IdentifiedArray(
				uniqueElements: blocks.map {
					PostLargeReducer.State(
						block: $0,
						isOwner: false,
						isFollowed: false,
						isLiked: false,
						likesCount: 0,
						commentCount: 0,
						enableFollowButton: true,
						withInViewNotifier: false,
						profileUserId: profileUserId
					)
				})
		}
	}
	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case posts(IdentifiedActionOf<PostLargeReducer>)
		case updateBlocks([InstaBlockWrapper], scrollTo: String?)
		case scrollTo(postId: String?)
		case task
	}
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .task:
				return .none
			case .posts:
				return .none
			case let .updateBlocks(blocks, scrollTo):
				state.blocks = blocks
				for block in blocks.reversed() {
					if state.posts[id: block.id] == nil {
						state.posts.insert(
							PostLargeReducer.State(
								block: block,
								isOwner: false,
								isFollowed: false,
								isLiked: false,
								likesCount: 0,
								commentCount: 0,
								enableFollowButton: false,
								withInViewNotifier: false,
								profileUserId: state.profileUserId
							),
							at: 0
						)
					}
				}
				let blockIds = blocks.map(\.id)
				state.posts.removeAll(where: { !blockIds.contains($0.id) })
				return .run { send in
					@Dependency(\.continuousClock) var clock
					try await clock.sleep(for: .milliseconds(300))
					await send(.scrollTo(postId: scrollTo))
				}
			case let .scrollTo(postId):
				state.scrollTo = postId
				return .none
			}
		}
		.forEach(\.posts, action: \.posts) {
			PostLargeReducer()
		}
	}
}

public struct PostsListView: View {
	@Bindable var store: StoreOf<PostsListReducer>
	@Environment(\.textTheme) var textTheme
	@State private var scrollTo: String?
	public init(store: StoreOf<PostsListReducer>) {
		self.store = store
	}
	public var body: some View {
		Group {
			ScrollViewReader { proxy in
				ScrollView {
					LazyVStack {
						ForEachStore(store.scope(state: \.posts, action: \.posts)) { postStore in
							blockBuilder(postStore: postStore)
								.id(postStore.block.id)
								.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: AppSpacing.lg, trailing: 0))
								.listRowSeparator(.hidden)
						}
//						if store.feed.feedPage.hasMore {
//							ProgressView()
//								.id("ProgressLoader")
//								.listRowSeparator(.hidden)
//								.frame(maxWidth: .infinity, alignment: .center)
//								.onAppear {
//									store.send(.feedPageNextPage)
//								}
//						}
					}
				}
				.scrollIndicators(.hidden)
				.onChange(of: scrollTo) { oldValue, newValue in
					if let newValue {
						withAnimation(.easeInOut(duration: 1.3)) {
							proxy.scrollTo(newValue)
						}
					}
				}
				.bind($store.scrollTo, to: $scrollTo)
			}
		}
	}
	
	@ViewBuilder
	private func blockBuilder(postStore: StoreOf<PostLargeReducer>) -> some View {
		Group {
			switch postStore.block {
			case .postLarge, .postSponsored:
				PostLargeView(
					store: postStore,
					postOptionsSettings: postStore.block.author.id == store.profileUserId ? PostOptionsSettings.owner : PostOptionsSettings.viewer,
					onTapAvatar: { userId in
//						store.send(.onTapAvatar(userId: userId))
					}
				)
			case .horizontalDivider:
				DividerBlock()
			case let .sectionHeader(sectionHeader):
				if sectionHeader.sectionType == .suggested {
					Text("Suggested for you")
						.font(textTheme.headlineSmall.font)
						.foregroundStyle(Assets.Colors.bodyColor)
				}
			default: EmptyView()
			}
		}
	}
}
