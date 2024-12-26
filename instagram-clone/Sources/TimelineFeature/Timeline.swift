import AppUI
import ComposableArchitecture
import Foundation
import InstaBlocks
import InstagramBlocksUI
import InstagramClient
import PostPreviewFeature
import Shared
import SwiftUI
import SearchFeature

private let timelinePageSize = 20

@Reducer
public struct TimelineReducer {
	public init() {}
	
	@Reducer(state: .equatable)
	public enum Destination {
		case search(SearchReducer)
	}
	
	@ObservableState
	public struct State: Equatable {
		var authorizedId: String
		var posts: IdentifiedArrayOf<PostSmallReducer.State> = []
		var search: String = ""
		var feedPage: FeedPage = .empty
		@Presents var destination: Destination.State?
		public init(authorizedId: String) {
			self.authorizedId = authorizedId
		}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case posts(IdentifiedActionOf<PostSmallReducer>)
		case fetchPost(page: Int)
		case fetchNextPagePost
		case postsResponse(blocks: [PostSmallBlock], isFirstPage: Bool)
		case refreshPosts
		case destination(PresentationAction<Destination.Action>)
		case task
		case onTapSearchBar
	}
	
	private enum Cancel: Hashable {
		case subscriptions
	}
	
	@Dependency(\.instagramClient.databaseClient) var databaseClient
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce {
			state,
				action in
			switch action {
			case .binding:
				return .none
			case .task:
				state.feedPage = .empty
				return .send(.fetchPost(page: state.feedPage.page))
			case let .fetchPost(page):
				return .run { send in
					let posts = try await databaseClient.getPost(page * timelinePageSize, timelinePageSize, false)
					await send(.postsResponse(blocks: posts.map { $0.toPostSmallBlock() }, isFirstPage: page == 0))
				} catch: { _, _ in
				}
			case .posts:
				return .none
			case let .postsResponse(blocks, isFirstPage):
				if isFirstPage {
					state.feedPage.blocks = blocks.map { InstaBlockWrapper.postSmall($0) }
					state.feedPage.page = 1
					state.feedPage.hasMore = blocks.count >= timelinePageSize
					state.feedPage.totalBlocks = blocks.count
					state.posts = IdentifiedArray(uniqueElements: state.feedPage.blocks.map {
						PostSmallReducer.State(
							block: $0.block as! PostSmallBlock,
							isOwner: state.authorizedId == $0.author.id,
							isLiked: false
						)
					})
				} else {
					state.feedPage.page += 1
					state.feedPage.blocks.append(contentsOf: blocks.map { InstaBlockWrapper.postSmall($0) })
					state.feedPage.hasMore = blocks.count >= timelinePageSize
					state.feedPage.totalBlocks += blocks.count
					state.posts.append(contentsOf: blocks.map {
						PostSmallReducer.State(
							block: $0,
							isOwner: state.authorizedId == $0.author.id,
							isLiked: false
						)
					})
				}
				return .none
			case .fetchNextPagePost:
				return .send(.fetchPost(page: state.feedPage.page + 1))
			case .refreshPosts:
				return .send(.fetchPost(page: 0))
			case .destination:
				return .none
			case .onTapSearchBar:
				state.destination = .search(SearchReducer.State())
				return .none
			}
		}
		.forEach(\.posts, action: \.posts) {
			PostSmallReducer()
		}
		.ifLet(\.$destination, action: \.destination) {
			Destination.body
		}
	}
}

public struct TimelineView: View {
	@Bindable var store: StoreOf<TimelineReducer>
	@Environment(\.textTheme) var textTheme
	@Environment(\.colorScheme) var colorScheme
	private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
	public init(store: StoreOf<TimelineReducer>) {
		self.store = store
	}

	public var body: some View {
		ScrollView {
			TextField("Search", text: .constant(""))
				.appTextField(
					foregroundColor: Assets.Colors.bodyColor,
					accentColor: Assets.Colors.bodyColor,
					backgroundColor: Assets.Colors.customReversedAdaptiveColor(colorScheme, light: Assets.Colors.brightGray, dark: Assets.Colors.dark),
					keyboardType: .default,
					returnKeyType: .next
				)
				.disabled(true)
				.onTapGesture {
					store.send(.onTapSearchBar)
				}
				.padding()
			LazyVGrid(columns: columns, spacing: 2) {
				ForEach(store.scope(state: \.posts, action: \.posts)) { postStore in
					Button {} label: {
						PostSmallView<EmptyView>(
							store: postStore,
							pinned: false
						)
						.frame(height: 140)
					}
					.fadeEffect()
					.contextMenu {
						Button {

						} label: {
							Label(postStore.isLiked ? "Unlike" : "Like", systemImage: postStore.isLiked ? "heart.fill" : "heart")
						}
						Button {} label: {
							Label("Comments", systemImage: "message")
						}
						
						Button {} label: {
							Label(postStore.isOwner ? "Share post" : "View UserProfile", systemImage: postStore.isOwner ? "location" : "person.circle")
						}
						
						Button {} label: {
							Label("Options", systemImage: "ellipsis")
						}
					} preview: {
						PostPreview(block: .postSmall(postStore.block))
							.frame(idealWidth: 400, idealHeight: 400 * 1.2)
							.frame(minWidth: 320, minHeight: 320 * 1.2)
					}
				}
			}
		}
		.toolbar(.hidden, for: .navigationBar)
		.refreshable {
			store.send(.refreshPosts)
		}
		.navigationDestination(item: $store.scope(state: \.destination?.search, action: \.destination.search)) { searchStore in
			SearchView(store: searchStore)
		}
		.task {
			await store.send(.task).finish()
		}
	}
}
