import AppUI
import ComposableArchitecture
import Foundation
import InstaBlocks
import InstagramBlocksUI
import Shared
import SwiftUI
import FeedUpdateRequestClient
import InstagramClient

@Reducer
public struct PostEditReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var post: InstaBlockWrapper
		var postMedia: PostMediaReducer.State
		var caption: String
		public init(post: InstaBlockWrapper) {
			self.post = post
			self.postMedia = PostMediaReducer.State(media: post.media ?? [], isLiked: false, currentMediaIndex: Shared(0))
			self.caption = post.caption
		}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case onTapBackButton
		case onTapConfirmEditButton
		case postMedia(PostMediaReducer.Action)
	}

	@Dependency(\.dismiss) var dismiss
	@Dependency(\.instagramClient.databaseClient.updatePost) var updatePost
	@Dependency(\.feedUpdateRequestClient.addFeedUpdateRequest) var addFeedUpdateRequest
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Scope(state: \.postMedia, action: \.postMedia) {
			PostMediaReducer()
		}
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .onTapBackButton:
				return .run { _ in
					
					await dismiss()
				}
			case .postMedia:
				return .none
			case .onTapConfirmEditButton:
				let updateCaption = state.caption.trimmingCharacters(in: .whitespacesAndNewlines)
				guard state.post.caption != updateCaption else {
					return .run { _ in
						await dismiss()
					}
				}
				return .run { [postId = state.post.id] _ in
					if let post = try await updatePost(postId, updateCaption) {
						await addFeedUpdateRequest(.update(newPost: post))
					}
					await dismiss()
				}
			}
		}
	}
}

public struct PostEditView: View {
	@Bindable var store: StoreOf<PostEditReducer>
	@Environment(\.textTheme) var textTheme
	public init(store: StoreOf<PostEditReducer>) {
		self.store = store
	}

	public var body: some View {
		VStack {
			HStack {
				Button {
					store.send(.onTapBackButton)
				} label: {
					Image(systemName: "xmark")
						.imageScale(.medium)
						.foregroundStyle(Assets.Colors.bodyColor)
				}
				.fadeEffect()
				Spacer()
				
				Text(store.post.author.username)
					.foregroundStyle(Assets.Colors.bodyColor)
				Spacer()
				Button {
					store.send(.onTapConfirmEditButton)
				} label: {
					Image(systemName: "checkmark")
						.imageScale(.medium)
						.foregroundStyle(Assets.Colors.blue)
				}
				.fadeEffect()
			}
			.font(textTheme.titleLarge.font)
			.fontWeight(.semibold)
			.padding(.vertical, AppSpacing.xlg)

			ScrollView {
				PostMediaView(store: store.scope(state: \.postMedia, action: \.postMedia))
					.frame(maxWidth: .infinity, maxHeight: 250)
				ZStack(alignment: .topLeading) {
					if store.caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
						Text("Edit Post")
							.foregroundColor(Color(.placeholderText))
							.padding(.horizontal, 4)
							.padding(.vertical, 8)
					}
					TextEditor(text: $store.caption)
						.lineLimit(nil)
						.scrollContentBackground(.hidden)
						.frame(maxWidth: .infinity, minHeight: 60)
				}
			}
		}
		.padding(AppSpacing.lg)
		.toolbar(.hidden, for: .navigationBar)
	}
}
