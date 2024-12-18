import AppUI
import ComposableArchitecture
import Foundation
import InstaBlocks
import InstagramBlocksUI
import InstagramClient
import Shared
import SwiftUI
import UserProfileFeature

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

	@Reducer(state: .equatable)
	public enum Destination {
		case userProfile(UserProfileReducer)
	}

	@ObservableState
	public struct State: Equatable {
		var profileUserId: String
		var feed: Feed
		var status: FeedStatus = .initial
		var post: IdentifiedArrayOf<PostLargeReducer.State> = []
		@Presents var destination: Destination.State?
		public init(profileUserId: String, feed: Feed = .empty) {
			self.profileUserId = profileUserId
			self.feed = feed
		}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case task
		case feedPageRequest(page: Int)
		case feedPageNextPage
//		case feedPageResponse(Result<FeedPage, Error>)
		case feedPageResponse(Result<FeedPage, Error>)
//		case feedPageFailure(Error)
		case post(IdentifiedActionOf<PostLargeReducer>)
		case destination(PresentationAction<Destination.Action>)
		case onTapAvatar(userId: String)
		case refreshFeedPage
	}

	@Dependency(\.instagramClient.databaseClient) var databaseClient

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
				return .run { [currentPage = state.feed.feedPage.page] send in
					await send(.feedPageRequest(page: currentPage))
				}

			case let .feedPageRequest(page):
				guard state.status != .loading else {
					return .none
				}
				state.status = .loading
				return .run { send in
					try await fetchFeedPage(send: send, page: page)
//					if let updatedFeedPage = blockPage as? FeedPage {
//						await send(.feedPageSuccess(updatedFeedPage))
//					}
				} catch: { error, send in
					await send(.feedPageResponse(.failure(error)))
				}
				.debounce(id: "FeedPageRequest", for: .milliseconds(500), scheduler: DispatchQueue.main)
				.cancellable(id: Cancel.feedPageRequest, cancelInFlight: true)
			case let .feedPageResponse(result):
				switch result {
				case let .success(feedPage):
					state.status = .populated
					let isRefresh = feedPage.page == 1
					let updatedFeedPage = FeedPage(
						blocks: isRefresh ? feedPage.blocks : state.feed.feedPage.blocks + feedPage.blocks,
						totalBlocks: isRefresh ? feedPage.totalBlocks : state.feed.feedPage.totalBlocks + feedPage.totalBlocks,
						page: feedPage.page,
						hasMore: feedPage.hasMore
					)
					state.feed.feedPage = updatedFeedPage
					let profileUserId = state.profileUserId

					let posts = state.feed.feedPage.blocks.map {
						PostLargeReducer.State(
							block: $0,
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
					if isRefresh {
						state.post = IdentifiedArray(uniqueElements: posts)
					} else {
						state.post.append(contentsOf: posts)
					}
					return .none
				case let .failure(error):
					state.status = .failure
					return .none
				}

//			case let .feedPageFailure(error):
//				state.status = .failure
//				return .none
			case .post:
				return .none
			case .destination:
				return .none
				/*void _handleOnPostTap(BuildContext context, {required BlockAction action}) =>
				 action.when(
			 navigateToPostAuthor: (action) =>
					 _navigateToPostAuthor(context, id: action.authorId),
			 navigateToSponsoredPostAuthor: (action) => _navigateToPostAuthor(
				 context,
				 id: action.authorId,
				 props: UserProfileProps.build(
					 isSponsored: true,
					 promoBlockAction: action,
					 sponsoredPost: block as PostSponsoredBlock,
				 ),
			 ),
		 );*/
			case let .onTapAvatar(userId):
				guard let block = state.feed.feedPage.blocks.first(where: { $0.author.id == userId }) else {
					return .none
				}
				let author = block.author
				let user = author.toUser()
				let props: UserProfileProps? = block.isSponsored ? UserProfileProps(
					isSponsored: true,
					sponsoredBlock: block.block as! PostSponsoredBlock,
					promoBlockAction: block.action
				) : nil
				let profileState = UserProfileReducer.State(
					authenticatedUserId: state.profileUserId,
					profileUser: user,
					profileUserId: userId,
					showBackButton: true,
					props: props
				)
				state.destination = .userProfile(profileState)
				return .none

			case .refreshFeedPage:
				guard state.status != .loading else {
					return .none
				}
				return .send(.feedPageRequest(page: 0))

			case .feedPageNextPage:
				return .send(.feedPageRequest(page: state.feed.feedPage.page))
			}
		}
		.forEach(\.post, action: \.post) {
			PostLargeReducer()
		}
		.ifLet(\.$destination, action: \.destination) {
			Destination.body
		}
	}

	typealias PostToBlockMapper = (Post) -> InstaBlockWrapper

	private func fetchFeedPage(
		send: Send<Action>,
		page: Int = 0,
		postToBlock: PostToBlockMapper? = nil,
		with sponsoredBlocks: Bool = true
	) async throws {
		let currentPage = page
		let posts = try await databaseClient.getPost(page * pageLimit, pageLimit, false)
		let newPage = currentPage + 1
		let hasMore = posts.count >= pageLimit
		var instaBlocks: [InstaBlockWrapper] = posts.map { post in
			if let postToBlock {
				postToBlock(post)
			} else {
				.postLarge(post.toPostLargeBlock())
			}
		}

		if hasMore, sponsoredBlocks {
			@Dependency(\.instagramClient.firebaseRemoteConfigClient) var firebaseRemoteConfigClient
			let sponsoredBlocksJsonString = try await firebaseRemoteConfigClient.fetchRemoteData(key: "sponsored_blocks")
			let sponsoredBlocks = try decoder.decode([InstaBlockWrapper].self, from: sponsoredBlocksJsonString.data(using: .utf8)!)
			for sponsoredBlock in sponsoredBlocks {
				instaBlocks.insert(sponsoredBlock, at: (2 ..< instaBlocks.count).randomElement()!)
			}
		}
		if !hasMore {
			instaBlocks.append(.horizontalDivider(DividerHorizontalBlock()))
			instaBlocks.append(.sectionHeader(SectionHeaderBlock()))
		}
		let feedPage = FeedPage(
			blocks: instaBlocks,
			totalBlocks: instaBlocks.count,
			page: newPage,
			hasMore: hasMore
		)
		await send(.feedPageResponse(.success(feedPage)))
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
		VStack(spacing: 0) {
			List {
				ForEachStore(store.scope(state: \.post, action: \.post)) { postStore in
					blockBuilder(postStore: postStore)
						.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: AppSpacing.lg, trailing: 0))
						.listRowSeparator(.hidden)
				}
				if store.feed.feedPage.hasMore {
					ProgressView()
						.listRowSeparator(.hidden)
						.frame(maxWidth: .infinity, alignment: .center)
						.onAppear {
							store.send(.feedPageNextPage)
						}
				}
			}
			.scrollIndicators(.hidden)
			.refreshable {
				store.send(.refreshFeedPage)
			}
			.listStyle(.plain)
		}
		.navigationDestination(
			item: $store.scope(
				state: \.destination?.userProfile,
				action: \.destination.userProfile
			)
		) { userProfileStore in
			UserProfileView(store: userProfileStore)
		}
		.task {
			await store.send(.task).finish()
		}
	}

	@ViewBuilder
	private func blockBuilder(postStore: StoreOf<PostLargeReducer>) -> some View {
		Group {
			switch postStore.block {
			case .postLarge, .postSponsored:
				PostLargeView(
					store: postStore,
					postOptionsSettings: postStore.block.author.id == store.profileUserId ? PostOptionsSettings.owner(
						onPostDelete: { _ in
						},
						onPostEdit: { _ in
						}
					) : PostOptionsSettings.viewer,
					onTapAvatar: { userId in
						store.send(.onTapAvatar(userId: userId))
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
