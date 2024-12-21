import AppUI
import ComposableArchitecture
import Foundation
import InstaBlocks
import InstagramBlocksUI
import InstagramClient
import Shared
import SwiftUI
import UserProfileFeature
import FeedUpdateRequestClient
import PostEditFeature
import CreatePostFeature
import MediaPickerFeature
import ChatsFeature





@Reducer
public struct FeedReducer {
	public init() {}

	@Reducer(state: .equatable)
	public enum Destination {
		case userProfile(UserProfileReducer)
		case postOptionsSheet(PostOptionsSheetReducer)
		case postEdit(PostEditReducer)
		case createPost(CreatePostReducer)
	}

	@ObservableState
	public struct State: Equatable {
		var profileUserId: String
		var feed: Feed
		var feedBody: FeedBodyReducer.State
		var mediaPicker: MediaPickerReducer.State
		var chats: ChatsReducer.State
		@Presents var destination: Destination.State?
		@Presents var alert: AlertState<Action.Alert>?
		public init(profileUserId: String, feed: Feed = .empty) {
			self.profileUserId = profileUserId
			self.feed = feed
			self.feedBody = FeedBodyReducer.State(profileUserId: profileUserId, feed: feed)
			self.mediaPicker = MediaPickerReducer.State(pickerConfiguration: MediaPickerView.Configuration(maxItems: 10, reels: false), nextAction: .createPost)
			self.chats = ChatsReducer.State()
		}
	}

	public enum Action: BindableAction {
		case alert(PresentationAction<Alert>)
		case binding(BindingAction<State>)
		case task
		case destination(PresentationAction<Destination.Action>)
		case feedBody(FeedBodyReducer.Action)
		case mediaPicker(MediaPickerReducer.Action)
		case chats(ChatsReducer.Action)
		case scrollToTop
		
		@CasePathable
		public enum Alert: Equatable {
			case confirmDeletePost(postId: String)
			case confirmBlockPostAuthor(userId: String)
		}
	}

	@Dependency(\.instagramClient.databaseClient) var databaseClient
	@Dependency(\.feedUpdateRequestClient) var feedUpdateRequestClient

	

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Scope(state: \.feedBody, action: \.feedBody) {
			FeedBodyReducer()
		}
		Scope(state: \.mediaPicker, action: \.mediaPicker) {
			MediaPickerReducer()
		}
		Scope(state: \.chats, action: \.chats) {
			ChatsReducer()
		}
		Reduce {
			state,
				action in
			switch action {
			case .binding: return .none
			case .feedBody:
				return .none
			case .mediaPicker:
				return .none
			case .chats:
				return .none
			case .destination:
				return .none
			case .alert:
				return .none
			case .task:
				return .none
			case .scrollToTop:
				return .none
			}
		}
		
		.ifLet(\.$destination, action: \.destination) {
			Destination.body
		}
		.ifLet(\.$alert, action: \.alert)

	}
}



public struct FeedView: View {
	@Environment(\.textTheme) var textTheme
	@Bindable var store: StoreOf<FeedReducer>
	public init(store: StoreOf<FeedReducer>) {
		self.store = store
	}

	public var body: some View {
		ScrollView(.horizontal) {
			
		}
	}
}
