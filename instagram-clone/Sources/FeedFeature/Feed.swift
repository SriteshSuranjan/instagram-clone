import AppUI
import ComposableArchitecture
import Foundation
import InstaBlocks
import InstagramBlocksUI
import Shared
import SwiftUI
import UserClient

public enum FeedStatus {
	case initial
	case loading
	case populated
	case failure
}

private let pageLimit = 10

@Reducer
public struct FeedReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var profileUserId: String
		var feed: Feed
		var status: FeedStatus = .initial
		var post: IdentifiedArrayOf<PostLargeReducer.State> = []
		public init(profileUserId: String, feed: Feed = .empty) {
			self.profileUserId = profileUserId
			self.feed = feed
		}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case task
		case feedPageRequest
		case feedPageResponse(Result<[PostLargeBlock], Error>)
		case post(IdentifiedActionOf<PostLargeReducer>)
	}

	@Dependency(\.userClient.databaseClient) var databaseClient

	private enum Cancel: Hashable {
		case feedPageRequest
	}

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce {
			state,
				action in
			switch action {
			case .binding:
				return .none

			case .task:
				return .run { send in
					await send(.feedPageRequest)
				}

			case .feedPageRequest:
				state.status = .loading
				return .run { [currentPage = state.feed.feedPage.page] send in
					let posts = try await databaseClient.getPost(currentPage * pageLimit, pageLimit, false)
					await send(.feedPageResponse(.success(posts.map { $0.toPostLargeBlock() })))
					//					let postLikers = try await withThrowingTaskGroup(of: (String, [User]).self) { group in
					//						for post in posts {
					//							group.addTask {
					//								let users = try await databaseClient.getPostLikersInFollowings(post.id, 0, 3)
					//								return (post.id, users)
					//							}
					//						}
					//						var likers: [(String, [User])] = []
					//						for try await liker in group {
					//							likers.append(liker)
					//						}
					//						return likers
					//					}

				} catch: { error, send in
					await send(.feedPageResponse(.failure(error)))
				}
				.cancellable(id: Cancel.feedPageRequest, cancelInFlight: true)
			case let .feedPageResponse(result):

				switch result {
				case let .success(postBlocks):
					state.status = .populated
					state.feed.feedPage.page = state.feed.feedPage.page + 1
					state.feed.feedPage.hasMore = postBlocks.count >= pageLimit
					state.feed.feedPage.blocks.append(contentsOf: postBlocks.map { InstaBlockWrapper.postLarge($0) })
					state.feed.feedPage.totalBlocks = state.feed.feedPage.totalBlocks
					let profileUserId = state.profileUserId
					let posts = postBlocks.map {
						PostLargeReducer.State(
							block: InstaBlockWrapper.postLarge($0),
							isOwner: $0.author.id == profileUserId,
							isFollowed: false,
							isLiked: false,
							likesCount: 0,
							commentCount: 0,
							enableFollowButton: true,
							withInViewNotifier: false,
							profileUserId: profileUserId
						)
					}
					state.post.append(contentsOf: posts)
					return .none
				case let .failure(error):
					state.status = .failure
					return .none
				}

			case .post:
				return .none
			}
		}
		.forEach(\.post, action: \.post) {
			PostLargeReducer()
		}
	}
}

extension Post {
	func toPostLargeBlock() -> PostLargeBlock {
		PostLargeBlock(
			id: id,
			author: PostAuthor(
				confirmed: author.id,
				avatarUrl: author.avatarUrl,
				username: author.username
			),
			createdAt: createdAt,
			caption: caption,
			media: media,
			action: .navigateToPostAuthor(
				NavigateToPostAuthorProfileAction(
					authorId: author.id
				)
			)
		)
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
			ForEachStore(store.scope(state: \.post, action: \.post)) { postStore in
				PostLargeView(
					store: postStore,
					postOptionsSettings: postStore.block.author.id == store.profileUserId ? PostOptionsSettings.owner(
						onPostDelete: { _ in
						},
						onPostEdit: { _ in
						}
					) : PostOptionsSettings.viewer
				)
				.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: AppSpacing.lg, trailing: 0))
				.listRowSeparator(.hidden)
			}
		}
		.listStyle(.plain)
		.task {
			await store.send(.task).finish()
		}
	}
}
