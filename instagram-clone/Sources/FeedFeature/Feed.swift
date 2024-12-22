import AppUI
import ComposableArchitecture
import FeedUpdateRequestClient
import Foundation
import InstaBlocks
import InstagramBlocksUI
import InstagramClient
import PostEditFeature
import Shared
import SwiftUI
import UserProfileFeature

private let pageLimit = 10

public enum FeedStatus {
	case initial
	case loading
	case populated
	case failure
}


@Reducer
public struct FeedReducer {
	public init() {}

	@Reducer(state: .equatable)
	public enum Destination {
		case userProfile(UserProfileReducer)
		case postOptionsSheet(PostOptionsSheetReducer)
		case postEdit(PostEditReducer)
	}

	@ObservableState
	public struct State: Equatable {
		var profileUserId: String
		var feed: Feed
		var status: FeedStatus = .initial
		var scrollToPosition: String?
		@Presents var destination: Destination.State?
		@Presents var alert: AlertState<Action.Alert>?
		var post: IdentifiedArrayOf<PostLargeReducer.State> = []
		public init(profileUserId: String, feed: Feed = .empty) {
			self.profileUserId = profileUserId
			self.feed = feed
		}
	}

	public enum Action: BindableAction {
		case alert(PresentationAction<Alert>)
		case binding(BindingAction<State>)
		case task
		case destination(PresentationAction<Destination.Action>)
		case feedPageRequest(page: Int)
		case feedPageNextPage
		case feedPageResponse(Result<FeedPage, Error>)
		case post(IdentifiedActionOf<PostLargeReducer>)
		case onTapAvatar(userId: String)
		case refreshFeedPage
		case onTapPostOptionSheet(optionType: PostOptionType, block: InstaBlockWrapper)
		case performFeedUpdateRequest(request: FeedUpdateRequest)
		case scrollToTop
		case delegate(Delegate)
		
		public enum Delegate {
			case onTapChatsButton
		}

		@CasePathable
		public enum Alert: Equatable {
			case confirmDeletePost(postId: String)
			case confirmBlockPostAuthor(userId: String)
		}
	}

	@Dependency(\.instagramClient.databaseClient) var databaseClient
	@Dependency(\.feedUpdateRequestClient) var feedUpdateRequestClient
	
	private enum Cancel: Hashable {
		case feedPageRequest
		case subscriptions
	}

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce {
			state,
				action in
			switch action {
			case let .alert(.presented(.confirmDeletePost(postId))):
				return .run { _ in
					try await databaseClient.deletePost(postId)
					await feedUpdateRequestClient.addFeedUpdateRequest(.delete(postId: postId))
				}
			case .alert:
				return .none
			case .binding:
				return .none
			case let .performFeedUpdateRequest(request):
				switch request {
				case let .create(newPost):
					let newBlock = newPost.toPostLargeBlock()
					state.feed.feedPage.blocks.insert(.postLarge(newBlock), at: 0)
					state.post.insert(PostLargeReducer.State(
						block: .postLarge(newBlock),
						isOwner: newBlock.author.id == state.profileUserId,
						isFollowed: false,
						isLiked: false,
						likesCount: 0,
						commentCount: 0,
						enableFollowButton: false,
						withInViewNotifier: false,
						profileUserId: state.profileUserId
					), at: 0)
				case let .delete(postId):
					state.feed.feedPage.blocks.removeAll(where: { $0.id == postId })
					state.post.remove(id: postId)
					state.feed.feedPage.totalBlocks -= 1
				case let .update(newPost):
					break
				}
				return .none
			case .task:
				return .run { [currentPage = state.feed.feedPage.page] send in
					await send(.feedPageRequest(page: currentPage))
					for await feedUpdateRequest in await feedUpdateRequestClient.feedUpdateRequests() {
						await send(.performFeedUpdateRequest(request: feedUpdateRequest), animation: .snappy)
					}
				}
				.cancellable(id: Cancel.subscriptions, cancelInFlight: true)
			case let .feedPageRequest(page):
				guard state.status != .loading else {
					return .none
				}
				state.status = .loading
				return .run { send in
					try await fetchFeedPage(send: send, page: page)
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
			case let .post(.element(id, subAction)):
				switch subAction {
				case let .header(.onTapPostOptionsButton(isOwner)):
					guard let block = state.feed.feedPage.blocks.first(where: { $0.id == id }) else {
						return .none
					}
					state.destination = .postOptionsSheet(PostOptionsSheetReducer.State(optionsSettings: isOwner ? .owner : .viewer, block: block))
					return .none

				default: return .none
				}
			case .post:
				return .none
			case .destination:
				return .none
			case let .onTapAvatar(userId):
				guard let block = state.feed.feedPage.blocks.first(where: { $0.author.id == userId }) else {
					return .none
				}
				let author = block.author
				let user = author.toUser()
				let props: UserProfileProps? = block.isSponsored ? UserProfileProps(
					isSponsored: true,
					sponsoredBlock: block.block as? PostSponsoredBlock,
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
			case .scrollToTop:
				state.scrollToPosition = state.feed.feedPage.blocks.first?.id
				return .none
			case .refreshFeedPage:
				guard state.status != .loading else {
					return .none
				}
				return .send(.feedPageRequest(page: 0))

			case .feedPageNextPage:
				return .send(.feedPageRequest(page: state.feed.feedPage.page))
			case let .onTapPostOptionSheet(optionType, block):
				switch optionType {
				case .editPost:
					state.destination = .postEdit(PostEditReducer.State(post: block))
					return .none
				case .deletePost:
					state.alert = AlertState(title: {
						TextState("Delete Post")
					}, actions: {
						ButtonState(role: .cancel) {
							TextState("Cancel")
						}
						ButtonState(role: .destructive, action: .send(.confirmDeletePost(postId: block.id))) {
							TextState("Delete")
						}
					}, message: {
						TextState("Are you sure to delete this post?")
					})
					return .none
				default: break // TODO: don't show again and block author
				}
				return .none
				
			case .delegate:
				return .none
			}
		}
		.forEach(\.post, action: \.post) {
			PostLargeReducer()
		}
		.ifLet(\.$destination, action: \.destination) {
			Destination.body
		}
		.ifLet(\.$alert, action: \.alert)
	}

	typealias PostToBlockMapper = (Post) -> InstaBlockWrapper

	private func feedUpdateRequestSubscriptions(send: Send<Action>) async {
		async let subscriptions: Void = {
			for await feedUpdateRequest in await feedUpdateRequestClient.feedUpdateRequests() {
				await send(.performFeedUpdateRequest(request: feedUpdateRequest), animation: .snappy)
			}
		}()
		_ = await subscriptions
	}

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

public struct FeedView: View {
	@Environment(\.textTheme) var textTheme
	@Bindable var store: StoreOf<FeedReducer>
	@State private var scrollToPosition: String?
	public init(store: StoreOf<FeedReducer>) {
		self.store = store
	}
	public var body: some View {
		Group {
			ScrollViewReader { proxy in
				ScrollView {
					LazyVStack {
						Section {
							ForEachStore(store.scope(state: \.post, action: \.post)) { postStore in
								blockBuilder(postStore: postStore)
									.id(postStore.block.id)
									.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: AppSpacing.lg, trailing: 0))
									.listRowSeparator(.hidden)
							}
							if store.feed.feedPage.hasMore {
								ProgressView()
									.id("ProgressLoader")
									.listRowSeparator(.hidden)
									.frame(maxWidth: .infinity, alignment: .center)
									.onAppear {
										store.send(.feedPageNextPage)
									}
							}
						} header: {
							appLogoView()
						}
					}
				}
				.scrollIndicators(.hidden)
				.refreshable {
					store.send(.refreshFeedPage)
				}
				.onChange(of: scrollToPosition) { oldValue, newValue in
					if let newValue {
						withAnimation(.easeInOut(duration: 1.3)) {
							proxy.scrollTo(newValue)
						}
					}
				}
				.bind($store.scrollToPosition, to: $scrollToPosition)
			}
		}
		.navigationDestination(
			item: $store.scope(
				state: \.destination?.userProfile,
				action: \.destination.userProfile
			)
		) { userProfileStore in
			UserProfileView(store: userProfileStore)
		}
		.sheet(
			item: $store.scope(
				state: \.destination?.postEdit,
				action: \.destination.postEdit
			)
		) { postEditStore in
			PostEditView(store: postEditStore)
				.presentationDetents([.medium, .large])
		}
		.sheet(
			item: $store.scope(
				state: \.destination?.postOptionsSheet,
				action: \.destination.postOptionsSheet
			)
		) { postOptionsSheetStore in
			PostOptionsSheetView(store: postOptionsSheetStore) { postOptionType, block in
				store.send(.onTapPostOptionSheet(optionType: postOptionType, block: block))
			}
			.presentationDetents([.height(140)])
			.presentationDragIndicator(.visible)
			.padding(.horizontal, AppSpacing.sm)
		}
		.alert($store.scope(state: \.alert, action: \.alert))
		.task {
			await store.send(.task).finish()
		}
	}
	
	@ViewBuilder
	private func appLogoView() -> some View {
		HStack {
			AppLogoView(
				width: 120,
				height: 50,
				color: Assets.Colors.bodyColor,
				contentMode: .fit
			)
			Spacer()
			Button {
				store.send(.delegate(.onTapChatsButton))
			} label: {
				Assets.Icons.chatCircle
					.view(width: 36, height: 36)
					.contentShape(.circle)
			}
			.fadeEffect()
		}
		.frame(maxWidth: .infinity)
		.padding(.horizontal, AppSpacing.sm)
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
