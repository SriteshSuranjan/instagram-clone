import AppUI
import BlurHashClient
import ComposableArchitecture
import Foundation
import Shared
import Supabase
import SwiftUI
import UnifiedBlurHash
import YPImagePicker
import UploadTaskClient

@Reducer
public struct CreatePostReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var selectedImageDetails: SelectedImageDetails
		var media: [MediaItem]
		var caption: String = ""
		public init(selectedImageDetails: SelectedImageDetails) {
			self.selectedImageDetails = selectedImageDetails
			@Dependency(\.uuid) var uuid
			self.media = selectedImageDetails.selectedFiles.map { file in
				file.isImage ? MediaItem.memoryImage(MemoryImageMedia(id: uuid().uuidString.lowercased(), url: file.selectedFile)) : MediaItem.memoryVideo(MemoryVideoMedia(id: uuid().uuidString.lowercased(), url: file.selectedFile))
			}
		}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case onShareButtonTapped(caption: String)
		case onTapBackButton
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
			ScrollView {
				TextField("Write Caption", text: $store.caption)
					.textFieldStyle(.roundedBorder)
					.padding()
					.frame(maxWidth: .infinity)
					.frame(height: 60)
			}
		}
		.padding(.horizontal, AppSpacing.lg)
		.toolbar(.hidden, for: .navigationBar)
		.safeAreaInset(edge: .bottom) {
			Button {
				store.send(.onShareButtonTapped(caption: "This is a post from Swift Client"))
			} label: {
				Text("Share")
					.frame(maxWidth: .infinity)
					.frame(height: 44)
					.contentShape(.rect)
			}
			.buttonStyle(.borderedProminent)
			.padding(.horizontal, AppSpacing.lg)
		}
	}
}
