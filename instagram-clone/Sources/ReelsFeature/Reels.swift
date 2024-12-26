import AppUI
import ComposableArchitecture
import Foundation
import InstaBlocks
import SwiftUI
import InstagramClient
import VideoPlayer

private let pageLimit = 10

@Reducer
public struct ReelsReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var authorizedId: String
		var reelsPage = ReelsPage(blocks: [], totalBlocks: 0, page: 0, hasMore: true)
		var reels: IdentifiedArrayOf<ReelReducer.State> = []
		public init(authorizedId: String) {
			self.authorizedId = authorizedId
		}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case reels(IdentifiedActionOf<ReelReducer>)
		case fetchReels(page: Int)
		case fetchReelsResponse(ReelsPage)
		case task
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
			case .reels:
				return .none
			case .task:
				return .run { [page = state.reelsPage.page] send in
					await send(.fetchReels(page: page))
				}
			case let .fetchReels(page):
				return .run { send in
					try await fetchReelsPage(send: send, page: page)
				}
			case let .fetchReelsResponse(reelsPage):
				let isRefresh = reelsPage.page == 1
				let updatedReelsPage = ReelsPage(
					blocks: isRefresh ? reelsPage.blocks : state.reelsPage.blocks + reelsPage.blocks,
					totalBlocks: isRefresh ? reelsPage.totalBlocks : state.reelsPage.totalBlocks + reelsPage.totalBlocks,
					page: reelsPage.page,
					hasMore: reelsPage.hasMore
				)
				state.reelsPage = updatedReelsPage
				
				let reels = state.reelsPage.blocks.map {
					ReelReducer.State(
						authorizedId: state.authorizedId,
						block: $0.block as! PostReelBlock,
						withSound: true,
						play: true
					)
				}
				if isRefresh {
					state.reels = IdentifiedArray(uniqueElements: reels)
				} else {
					state.reels.append(contentsOf: reels)
				}
				VideoPlayer.preload(
					urls: state.reelsPage.blocks.compactMap { URL(string: $0.block.firstMediaUrl ?? "") })
				return .none
			}
		}
		.forEach(\.reels, action: \.reels) {
			ReelReducer()
		}
	}
	
	private func fetchReelsPage(send: Send<Action>, page: Int = 0) async throws {
		let currentPage = page
		let posts = try await databaseClient.getPost(page * pageLimit, pageLimit, true)
		let newPage = currentPage + 1
		let hasMore = posts.count >= pageLimit
		let instaBlocks: [InstaBlockWrapper] = posts.map { post in
				.postReel(post.toPostReelBlock())
		}
		let reelsPage = ReelsPage(
			blocks: instaBlocks,
			totalBlocks: instaBlocks.count,
			page: newPage,
			hasMore: hasMore
		)
		await send(.fetchReelsResponse(reelsPage))
	}
}

public struct ReelsView: View {
	@Bindable var store: StoreOf<ReelsReducer>
	@Environment(\.textTheme) var textTheme
	@State private var playReelId: String?
	public init(store: StoreOf<ReelsReducer>) {
		self.store = store
	}

	public var body: some View {
		GeometryReader { proxy in
			ScrollView(.vertical) {
				LazyVStack(spacing: 0) {
					ForEach(
						store.scope(state: \.reels, action: \.reels)
					) { reelStore in
						ReelView(
							store: reelStore,
							play: Binding(
								get: { playReelId == reelStore.block.id },
								set: { playing in
									debugPrint(playing, #line)
									if !playing {
										playReelId = nil
									} else {
										playReelId = reelStore.block.id
									}
								}
							)
						)
							.scrollTargetLayout()
							.frame(height: proxy.size.height)
							.id(reelStore.block.id)
					}
					
				}
			}
			.scrollPosition(id: $playReelId)
			.scrollIndicators(.hidden)
			.scrollTargetLayout()
			.scrollTargetBehavior(.paging)
		}
		.onDisappear {
			playReelId = nil
		}
		.toolbar(.hidden, for: .navigationBar)
		.ignoresSafeArea()
		.task {
			await store.send(.task).finish()
			playReelId = store.reels.first?.block.id
		}
	}
}
