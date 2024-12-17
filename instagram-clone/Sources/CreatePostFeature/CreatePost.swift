import AppUI
import BlurHashClient
import ComposableArchitecture
import Foundation
import InstagramBlocksUI
import Shared
import Supabase
import SwiftUI
import UnifiedBlurHash
import UploadTaskClient
import YPImagePicker

@Reducer
public struct CreatePostReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var selectedImageDetails: SelectedImageDetails
		var caption: String = ""
		var postMedia: PostMediaReducer.State
		public init(selectedImageDetails: SelectedImageDetails) {
			self.selectedImageDetails = selectedImageDetails
			@Dependency(\.uuid) var uuid
			debugPrint(selectedImageDetails.selectedFiles.map { $0.selectedFile.path() })
			let media = selectedImageDetails.selectedFiles.map { file in
				file.isImage ? MediaItem.memoryImage(MemoryImageMedia(id: uuid().uuidString.lowercased(), url: "", previewData: file.selectedData)) : MediaItem.memoryVideo(MemoryVideoMedia(id: uuid().uuidString.lowercased(), url: file.selectedFile.path(), previewData: file.selectedData))
			}
			self.postMedia = PostMediaReducer.State(
				media: media,
				isLiked: false,
				currentMediaIndex: Shared(0),
				showCurrentIndex: false,
				withLikeOverlay: false,
				autoHideCurrentIndex: false,
				videoMuted: true
			)
		}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case onShareButtonTapped(caption: String)
		case onTapBackButton
		case postMedia(PostMediaReducer.Action)
		case delegate(Delegate)
		public enum Delegate {
			case popToRoot
		}
	}

	@Dependency(\.blurHashClient) var blurHashClient
	@Dependency(\.uuid) var uuid
	@Dependency(\.dismiss) var dismiss
	@Dependency(\.uploadTaskClient) var uploadTaskClient

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce {
			state,
				action in
			switch action {
			case .postMedia:
				return .none
			case .binding:
				return .none
			case let .onShareButtonTapped(caption):
				return .run { [selectedFiles = state.selectedImageDetails.selectedFiles] send in
					@Dependency(\.uuid) var uuid
					let postUploadTask = PostUploadTask(postId: uuid().uuidString.lowercased(), caption: caption, files: selectedFiles)
					await uploadTaskClient.uploadTask(task: .post(postUploadTask))
					await send(.delegate(.popToRoot))
				}
			case .onTapBackButton:
				return .run { _ in
					await dismiss()
				}
			case .delegate:
				return .none
			}
		}
	}
}

public struct CreatePostView: View {
	@Bindable var store: StoreOf<CreatePostReducer>
	public init(store: StoreOf<CreatePostReducer>) {
		self.store = store
	}

	public var body: some View {
		VStack {
			AppNavigationBar(title: "New Post") {
				store.send(.onTapBackButton)
			}
			PostMediaView(store: store.scope(state: \.postMedia, action: \.postMedia))
				.frame(maxWidth: .infinity, maxHeight: 250)
			ScrollView {
				ZStack(alignment: .topLeading) {
					if store.caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
						Text("Write caption")
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
		.padding(.horizontal, AppSpacing.lg)
		.toolbar(.hidden, for: .navigationBar)
		.safeAreaInset(edge: .bottom) {
			Button {
				store.send(.onShareButtonTapped(caption: store.caption.trimmingCharacters(in: .whitespacesAndNewlines)))
			} label: {
				Text("Share")
					.frame(maxWidth: .infinity)
					.contentShape(.rect)
			}
			.buttonStyle(.borderedProminent)
			.frame(height: 50)
			.padding(.horizontal, AppSpacing.lg)
		}
	}
}
