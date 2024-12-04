import Foundation
import SwiftUI
import ComposableArchitecture
import AppUI
import YPImagePicker
import Shared
import BlurHashClient

@Reducer
public struct CreatePostReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var selectedImageDetails: SelectedImageDetails
		var media: [MediaItem]
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
	}
	
	@Dependency(\.blurHashClient) var blurHashClient
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case let .onShareButtonTapped(caption):
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
		Text("Create Post")
	}
}
